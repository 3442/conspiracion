// $ sbt "runMain vexriscv.demo.GenW3DHost"             :((git)-[master]  03:59:49
// Agregar a mano: verilator tracing_off
// Quitar `timescale
// TODO: Quitar excesos?

package vexriscv.demo

import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba4.axi.Axi4ReadOnly
import spinal.lib.cpu.riscv.debug.DebugTransportModuleParameter
import spinal.lib.eda.altera.{InterruptReceiverTag, QSysify, ResetEmitterTag}
import vexriscv.ip.{DataCacheConfig, InstructionCacheConfig}
import vexriscv.ip.fpu.FpuParameter
import vexriscv.plugin._
import vexriscv.{VexRiscv, VexRiscvConfig, plugin}

object GenW3DHost extends App{
  SpinalConfig(
    defaultConfigForClockDomains = ClockDomainConfig(
      resetKind = spinal.core.ASYNC,
      resetActiveLevel = spinal.core.LOW
    )
  ).generateVerilog({
    val cpuConfig = VexRiscvConfig(
      plugins = List(
        new IBusCachedPlugin(
          prediction = DYNAMIC_TARGET,
          resetVector = 0x00000000l,
          historyRamSizeLog2 = 8,
          compressedGen = true,
          injectorStage = true,
          relaxedPcCalculation = true,
          config = InstructionCacheConfig(
            cacheSize = 4096*2,
            bytePerLine =32,
            wayCount = 1,
            addressWidth = 32,
            cpuDataWidth = 32,
            memDataWidth = 32,
            catchIllegalAccess = true,
            catchAccessFault = true,
            asyncTagMemory = false,
            twoCycleRam = false,
            twoCycleCache = true
          )
        ),
        new DBusCachedPlugin(
          config = new DataCacheConfig(
            cacheSize         = 4096*2,
            bytePerLine       = 32,
            wayCount          = 1,
            addressWidth      = 32,
            cpuDataWidth      = 32,
            memDataWidth      = 32,
            catchAccessError  = true,
            catchIllegal      = true,
            catchUnaligned    = true
          )
        ),
        new StaticMemoryTranslatorPlugin(
          ioRange      = _(31 downto 26) >= 0x7 // Inicia en 0x1c000000 (0x3c000000 para HPS)
        ),
        new DecoderSimplePlugin(
          catchIllegalInstruction = true
        ),
        new RegFilePlugin(
          regFileReadyKind = plugin.SYNC,
          zeroBoot = false
        ),
        new IntAluPlugin,
        new FpuPlugin(
          p = new FpuParameter(
            withDouble = false,
            asyncRegFile = false,
            mulWidthA = 17,
            mulWidthB = 17
          )
        ),
        new SrcPlugin(
          separatedAddSub = false,
          executeInsertion = true
        ),
        new FullBarrelShifterPlugin(earlyInjection = true),
        new HazardSimplePlugin(
          bypassExecute           = true,
          bypassMemory            = true,
          bypassWriteBack         = true,
          bypassWriteBackBuffer   = true,
          pessimisticUseSrc       = false,
          pessimisticWriteRegFile = false,
          pessimisticAddressMatch = false
        ),
        new MulPlugin,
        new DivPlugin,
        new CsrPlugin(CsrPluginConfig.small(0x00000000l).copy(
          ebreakGen = true,
          withPrivilegedDebug = true
        )),
        new EmbeddedRiscvJtag(
          p = DebugTransportModuleParameter(
            addressWidth = 7,
            version      = 1,
            idle         = 7
          ),
          debugCd = ClockDomain.current,
          withTunneling = false,
          withTap = true
        ),
        new BranchPlugin(
          earlyBranch = false,
          catchAddressMisaligned = true
        ),
        new YamlPlugin("cpu0.yaml")
      )
    )

    val cpu = new VexRiscv(cpuConfig)

    cpu.rework {
      var iBus : Axi4ReadOnly = null
      for (plugin <- cpuConfig.plugins) plugin match {
        case plugin: IBusSimplePlugin => {
          plugin.iBus.setAsDirectionLess() //Unset IO properties of iBus
          iBus = master(plugin.iBus.toAxi4ReadOnly().toFullConfig())
            .setName("iBusAxi")
            .addTag(ClockDomainTag(ClockDomain.current)) //Specify a clock domain to the iBus (used by QSysify)
        }
        case plugin: IBusCachedPlugin => {
          plugin.iBus.setAsDirectionLess() //Unset IO properties of iBus
          iBus = master(plugin.iBus.toAxi4ReadOnly().toFullConfig())
            .setName("iBusAxi")
            .addTag(ClockDomainTag(ClockDomain.current)) //Specify a clock domain to the iBus (used by QSysify)
        }
        case plugin: DBusSimplePlugin => {
          plugin.dBus.setAsDirectionLess()
          master(plugin.dBus.toAxi4Shared().toAxi4().toFullConfig())
            .setName("dBusAxi")
            .addTag(ClockDomainTag(ClockDomain.current))
        }
        case plugin: DBusCachedPlugin => {
          plugin.dBus.setAsDirectionLess()
          master(plugin.dBus.toAxi4Shared().toAxi4().toFullConfig())
            .setName("dBusAxi")
            .addTag(ClockDomainTag(ClockDomain.current))
        }
        case _ =>
      }
      for (plugin <- cpuConfig.plugins) plugin match {
        case plugin: CsrPlugin => {
          plugin.externalInterrupt
            .addTag(InterruptReceiverTag(iBus, ClockDomain.current))
          plugin.timerInterrupt
            .addTag(InterruptReceiverTag(iBus, ClockDomain.current))
        }
        case _ =>
      }
    }

    cpu
  })
}
