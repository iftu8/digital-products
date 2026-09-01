# Project AETHER-OS: An Advanced AI Infrastructure Engineering Manual

## Complete Architectural Guide for Senior AI Systems Engineers Building Zero-Latency, Sandboxed Multi-Agent Runtime Environments

---

**Author:** AI Systems Engineering Group
**Version:** 1.0.0
**Date:** October 26, 2023
**Copyright:** © 2023 AETHER Systems Inc. All rights reserved.

---

## Table of Contents

**Introduction: The Dawn of AETHER-OS**
*   The Paradigm Shift: From Monolithic AI to Autonomous Agent Swarms
*   AETHER-OS Vision: Zero-Latency, Hard-Real-Time, Sandboxed Execution
*   Target Audience and Core Principles

**Chapter 1: Bare-Metal WebAssembly (WASM) Isolation Runtime**
*   1.1 The Imperative for Secure and Performant Isolation
*   1.2 Architectural Overview of the AETHER-WASM Micro-Runtime
*   1.3 Custom `no_std` Memory Management for WASM Linear Memory
    *   1.3.1 Arena Allocation Strategy
    *   1.3.2 Memory Bounding and Protection Mechanisms
*   1.4 WASM Module Loading and Instantiation
*   1.5 Preemptive Execution Interruption and Context Preservation
*   1.6 Rust Implementation: AETHER-WASM Memory Manager

**Chapter 2: Zero-Copy GPU IPC & Unified Memory Virtualization**
*   2.1 The Bottleneck of Data Movement in Multi-Agent AI
*   2.2 NVIDIA Unified Memory (UM) as the Foundation
*   2.3 GPU Inter-Process Communication (IPC) for Tensor Sharing
    *   2.3.1 Producer-Consumer Model with IPC Handles
    *   2.3.2 Ensuring Memory Coherency and Access Control
*   2.4 Virtualizing GPU Memory for Isolated Sandboxes
*   2.5 CUDA C++ Kernel and Rust FFI Bridge Implementation
    *   2.5.1 CUDA Producer Kernel
    *   2.5.2 CUDA Consumer Kernel
    *   2.5.3 Rust FFI Bridge for IPC Management

**Chapter 3: Deterministic Swarm Scheduler & Vector Clock Consensus**
*   3.1 Orchestrating Agent Swarms: The Need for Determinism
*   3.2 AETHER-OS Preemptive Round-Robin Agent Scheduler
    *   3.2.1 Agent Control Blocks (ACBs) and Context Switching
    *   3.2.2 Time Slicing and Quantum Management
*   3.3 Deadlock Resolution Strategies in a Multi-Agent Kernel
*   3.4 Conflict-Free Replicated Data Types (CRDTs) for Agent State
*   3.5 Lock-Free Vector Clock Implementation for Causal Ordering
    *   3.5.1 The Challenge of Distributed Time
    *   3.5.2 Atomic Operations for Vector Clock Updates
*   3.6 Rust Implementation: Agent Scheduler and Vector Clock

**Chapter 4: Dynamic Tool-Calling Memory Bus & Context Switching**
*   4.1 Bridging Agents to the External World: The Tool-Calling Bus
*   4.2 AETHER-OS Memory Bus Architecture
    *   4.2.1 Virtual Address Space Management for Agents
    *   4.2.2 Shared Memory Regions for Tool Access and Vector Stores
*   4.3 Hard-Real-Time Context Switching for Agent Execution
    *   4.3.1 CPU Register Preservation and Restoration
    *   4.3.2 WASM Runtime State Management
*   4.4 Hardware-Accelerated Similarity Search for Long-Term Memory
    *   4.4.1 Integrating Vector Store Search with the Memory Bus
    *   4.4.2 Leveraging GPU Acceleration for k-NN Search
*   4.5 Rust Implementation: Memory Bus and Context Switching Primitives

---

## Introduction: The Dawn of AETHER-OS

### The Paradigm Shift: From Monolithic AI to Autonomous Agent Swarms

The landscape of Artificial Intelligence is undergoing a profound transformation. Traditional monolithic AI models, while powerful, often operate as isolated black boxes, lacking the agility, resilience, and emergent intelligence required for complex, dynamic environments. The future belongs to autonomous AI agent swarms – collections of specialized, self-governing entities that collaborate, communicate, and dynamically adapt to achieve overarching objectives. These swarms promise unparalleled capabilities in areas such as adaptive robotics, real-time decision systems, complex simulations, and distributed intelligence.

However, realizing this vision demands a fundamental rethinking of the underlying infrastructure. Conventional operating systems, designed for human-centric computing, introduce unacceptable latencies, security vulnerabilities, and resource contention when tasked with managing hundreds or thousands of concurrently executing, highly interactive AI agents. The need for a dedicated, purpose-built operating system kernel becomes paramount.

### AETHER-OS Vision: Zero-Latency, Hard-Real-Time, Sandboxed Execution

Project AETHER-OS emerges as the answer to this critical infrastructure gap. It is an ambitious endeavor to engineer a low-level operating system kernel specifically optimized for the unique demands of autonomous AI agent swarms. Our vision for AETHER-OS is anchored in three core principles:

1.  **Zero-Latency Execution:** Every operation, from inter-agent communication to memory access and context switching, must be engineered for microsecond-level responsiveness. This necessitates bare-metal control, highly optimized data paths, and avoidance of traditional OS overheads.
2.  **Hard-Real-Time Guarantees:** For mission-critical AI applications, predictability is as vital as speed. AETHER-OS provides deterministic execution, ensuring that agents meet their deadlines and system behavior remains consistent under varying loads.
3.  **Sandboxed Multi-Agent Environments:** Autonomous agents, especially those operating in open or adversarial environments, can exhibit emergent, unpredictable, or even malicious behavior. AETHER-OS enforces robust, hardware-assisted isolation, ensuring that each agent operates within its strict resource boundaries, preventing interference and enhancing system resilience.

AETHER-OS is not merely an OS; it is a meticulously crafted foundation for the next generation of AI. It addresses the inherent challenges of managing concurrent, heterogeneous AI workloads, enabling seamless collaboration, efficient resource utilization, and unparalleled security for agent-based systems.

### Target Audience and Core Principles

This manual is tailored for **Principal Systems Architects** and **Senior AI Systems Engineers** who possess a deep understanding of low-level systems programming, operating system internals, and high-performance computing. It assumes familiarity with Rust, C, and CUDA, and a keen interest in pushing the boundaries of what's possible in AI infrastructure.

The core principles guiding the design and implementation of AETHER-OS, as detailed in this guide, include:

*   **Memory Safety First:** Leveraging Rust's ownership model to prevent common memory-related vulnerabilities at the kernel level.
*   **Hardware Proximity:** Minimizing abstraction layers to directly exploit underlying hardware capabilities, including CPU features (MMUs, MPUs) and specialized AI accelerators (GPUs).
*   **Concurrency and Parallelism:** Designing for inherently parallel workloads, optimizing for multi-core CPUs and massively parallel GPUs.
*   **Determinism:** Eliminating sources of non-determinism wherever possible to ensure predictable and repeatable agent swarm behavior.
*   **Minimalism:** Avoiding unnecessary features and focusing solely on the core requirements for AI agent execution.

By adhering to these principles, AETHER-OS aims to unlock unprecedented performance, reliability, and security for the most demanding autonomous AI applications.

---

## Chapter 1: Bare-Metal WebAssembly (WASM) Isolation Runtime

### 1.1 The Imperative for Secure and Performant Isolation

Autonomous AI agents, by their very nature, are designed to be dynamic, adaptive, and often operate with a degree of autonomy that can lead to unpredictable behavior. When multiple such agents coexist within a shared environment, ensuring their isolation becomes paramount. Traditional process-based isolation, while robust, incurs significant overhead due to context switching, address space management, and IPC mechanisms. Virtual machines offer stronger isolation but introduce even higher latency.

WebAssembly (WASM) presents a compelling alternative. Its design as a portable, low-level bytecode format, coupled with its inherent memory safety guarantees and sandboxing capabilities, makes it an ideal candidate for running untrusted AI agent code. However, standard WASM runtimes often rely on a host operating system and its `std` library, introducing layers of abstraction and non-determinism that are unacceptable for AETHER-OS's zero-latency, bare-metal requirements.

AETHER-OS mandates a custom, bare-metal WASM micro-runtime designed for:
*   **Microsecond Sandbox Creation:** Rapid instantiation of new agent execution environments.
*   **Precise Memory Bounding:** Strict enforcement of memory limits for each agent's linear memory, preventing unauthorized access or resource exhaustion.
*   **Preemptive Execution Interruption:** The ability to pause, resume, or terminate an agent's execution deterministically and with minimal overhead, crucial for scheduling, resource management, and safety protocols.
*   **Minimal Overhead:** Operating directly on hardware, bypassing traditional OS layers to achieve near-native performance.

### 1.2 Architectural Overview of the AETHER-WASM Micro-Runtime

The AETHER-WASM micro-runtime is a `no_std` Rust kernel component responsible for loading, sandboxing, and executing WASM modules representing individual AI agents. It does not rely on libc or any standard OS services. Instead, it interacts directly with the system's Memory Management Unit (MMU) or Memory Protection Unit (MPU) for memory isolation, and a custom scheduler for preemption.

Key architectural components include:

1.  **WASM Module Loader:** Parses a minimal WASM binary, extracting function definitions, imports, exports, and linear memory requirements.
2.  **Memory Manager (AETHER-MM):** The core of the sandboxing mechanism. It allocates a dedicated linear memory region for each WASM instance, enforces strict bounds, and manages memory protection.
3.  **Execution Engine (AETHER-EE):** A highly optimized, potentially ahead-of-time (AOT) compiler or a fast interpreter that translates WASM bytecode into native machine code and executes it. For this manual, we focus on the runtime's interaction with a conceptual execution engine.
4.  **Runtime Context:** Stores the current state of a WASM instance, including its linear memory base address, stack pointer, program counter, and any necessary host-provided functions (imports).
5.  **Host Functions (WASI-Lite):** A minimal set of kernel-provided functions that WASM agents can import to interact with the AETHER-OS environment (e.g., for IPC, logging, tool-calling).

### 1.3 Custom `no_std` Memory Management for WASM Linear Memory

Running WASM without `std` means we cannot use `Vec`, `Box`, `HashMap`, or the global allocator. We must implement our own memory management primitives. For agent sandboxes, an arena allocation strategy combined with hardware-assisted memory protection is ideal for speed and security.

#### 1.3.1 Arena Allocation Strategy

Each WASM agent instance will be assigned its own dedicated memory arena. This arena will serve as its linear memory, stack, and any internal data structures. Arena allocation is simple and fast: memory is allocated linearly from a pre-reserved block, and deallocation (of the entire arena) is a single operation.

```rust
// src/memory/arena.rs
#![no_std]

use core::ptr::{self, NonNull};
use core::alloc::{Layout, Allocator};

/// Represents a contiguous block of memory managed as an arena.
/// Allocation is sequential, deallocation is all-at-once.
pub struct Arena {
    start: *mut u8,
    end: *mut u8,
    current: *mut u8,
}

impl Arena {
    /// Creates a new arena from a raw memory region.
    /// `base` is the starting address, `size` is the total size in bytes.
    /// This function assumes `base` points to valid, accessible memory.
    pub unsafe fn new(base: *mut u8, size: usize) -> Self {
        Arena {
            start: base,
            end: base.add(size),
            current: base,
        }
    }

    /// Allocates a block of memory from the arena.
    /// Returns a `NonNull<[u8]>` on success, or `None` if out of memory.
    /// Ensures alignment.
    pub fn alloc(&mut self, layout: Layout) -> Option<NonNull<[u8]>> {
        let align_offset = self.current.align_offset(layout.align());
        let aligned_ptr = unsafe { self.current.add(align_offset) };

        if aligned_ptr < self.start || aligned_ptr >= self.end { // Check for overflow/underflow
            return None;
        }

        let new_current = unsafe { aligned_ptr.add(layout.size()) };

        if new_current > self.end {
            // Not enough space
            return None;
        }

        let slice = unsafe { core::slice::from_raw_parts_mut(aligned_ptr, layout.size()) };
        self.current = new_current;
        NonNull::new(slice)
    }

    /// Resets the arena, making all previously allocated memory available again.
    /// Does not deallocate the underlying memory region.
    pub fn reset(&mut self) {
        self.current = self.start;
    }

    /// Returns the base address of the arena.
    pub fn base(&self) -> *mut u8 {
        self.start
    }

    /// Returns the total size of the arena.
    pub fn size(&self) -> usize {
        unsafe { self.end.offset_from(self.start) as usize }
    }

    /// Returns the amount of memory currently used in the arena.
    pub fn used_size(&self) -> usize {
        unsafe { self.current.offset_from(self.start) as usize }
    }
}

// Implement the `Allocator` trait for convenience, though `alloc` is used directly.
// This requires nightly Rust for now, but the concept is demonstrated.
// For stable `no_std` without `alloc` crate, direct `alloc` calls are typical.
/*
#[cfg(feature = "allocator_api")] // Requires `allocator_api` feature on nightly
unsafe impl Allocator for Arena {
    fn allocate(&self, layout: Layout) -> Result<NonNull<[u8]>, AllocError> {
        let align_offset = self.current.align_offset(layout.align());
        let aligned_ptr = unsafe { self.current.add(align_offset) };

        if aligned_ptr < self.start || aligned_ptr >= self.end {
            return Err(AllocError);
        }

        let new_current = unsafe { aligned_ptr.add(layout.size()) };

        if new_current > self.end {
            return Err(AllocError);
        }

        self.current = new_current; // Note: `self` is `&self`, need interior mutability for actual allocator
                                    // For this example, direct `alloc` on `&mut self` is more practical.
        NonNull::new(aligned_ptr as *mut [u8]).ok_or(AllocError)
    }

    unsafe fn deallocate(&self, ptr: NonNull<u8>, layout: Layout) {
        // Arena deallocation is a no-op for individual blocks, only a full reset.
        // This makes it suitable for "allocate once, free all" scenarios.
    }
}
*/
```

#### 1.3.2 Memory Bounding and Protection Mechanisms

The `Arena` provides logical bounding. For *hardware-enforced* protection, AETHER-OS leverages the CPU's Memory Management Unit (MMU) or, for simpler embedded systems, a Memory Protection Unit (MPU). Each WASM agent's linear memory is mapped into a distinct virtual address space or assigned a unique memory region with specific access permissions.

When a WASM instance is created:
1.  A physical memory block is reserved for its arena.
2.  The AETHER-OS kernel configures the MMU/MPU to map this physical block into the agent's virtual address space (or define its protected region).
3.  Access permissions (read/write/execute) are set strictly. Any attempt by the WASM agent to access memory outside its allocated region triggers a hardware fault, which the kernel intercepts and handles (e.g., terminating the agent).

```rust
// src/memory/mmu.rs (Conceptual, highly architecture-specific)
#![no_std]

/// Represents a virtual memory page table entry (PTE) or MPU region configuration.
#[repr(C)]
pub struct PageTableEntry {
    // fields like physical address, permissions (R/W/X), caching attributes, etc.
    // specific to ARMv8, x86-64, RISC-V MMU architectures.
    // For simplicity, we model a conceptual page table entry.
    pub phys_addr: usize,
    pub flags: u64, // e.g., PRESENT, WRITABLE, USER_ACCESSIBLE, NO_EXECUTE
}

/// Flags for memory protection.
#[allow(non_upper_case_globals)]
pub mod MmuFlags {
    pub const PRESENT: u64 = 1 << 0;
    pub const WRITABLE: u64 = 1 << 1;
    pub const USER_ACCESSIBLE: u64 = 1 << 2; // Can be accessed by user-level WASM agents
    pub const NO_EXECUTE: u64 = 1 << 3; // Data pages should not be executable
    pub const WASM_LINEAR_MEMORY: u64 = USER_ACCESSIBLE | WRITABLE | NO_EXECUTE;
    pub const WASM_CODE_MEMORY: u64 = USER_ACCESSIBLE | PRESENT; // Executable, usually read-only
}

/// A conceptual MMU interface for AETHER-OS.
pub struct MmuController;

impl MmuController {
    /// Initializes the MMU/MPU. This would involve setting up base page tables.
    /// For a real system, this is a complex boot-time operation.
    pub unsafe fn init() {
        // Architecture-specific MMU initialization (e.g., loading CR3 on x86, TTBR0/1 on ARM)
        // Set up kernel page tables, identity map critical regions.
        // This is a placeholder for a deep hardware-level setup.
        // For an MPU, this would involve configuring MPU regions.
        // AETHER-OS will run in privileged mode and agents in unprivileged mode.
        core::hint::black_box(()); // Prevent optimization of empty block
    }

    /// Maps a physical memory region to a virtual address range for a specific agent.
    /// `agent_id`: Identifier for the agent (used to select its page table or MPU context).
    /// `virt_addr`: The virtual address within the agent's address space.
    /// `phys_addr`: The physical memory address.
    /// `size`: Size of the region to map.
    /// `flags`: Permissions (read, write, execute, user access).
    pub unsafe fn map_region(
        agent_id: u32,
        virt_addr: usize,
        phys_addr: usize,
        size: usize,
        flags: u64,
    ) -> Result<(), &'static str> {
        // In a real MMU, this would involve:
        // 1. Locating the agent's page table root.
        // 2. Traversing the page table hierarchy to find or create PTEs for `virt_addr`.
        // 3. Populating PTEs with `phys_addr` and `flags`.
        // 4. Flushing TLB entries if necessary.
        // For MPU, this involves configuring MPU region registers.

        // Placeholder for complex MMU/MPU logic.
        // We assume page granularity for mapping.
        let page_size = 4096; // Typical page size
        let num_pages = (size + page_size - 1) / page_size;

        for i in 0..num_pages {
            let current_virt = virt_addr + i * page_size;
            let current_phys = phys_addr + i * page_size;

            // Simplified: Add entry to a conceptual "page_table" for `agent_id`
            // In reality, this is a multi-level table walk.
            // AETHER_OS_AGENT_PAGE_TABLES[agent_id].add_entry(current_virt, current_phys, flags);
            core::hint::black_box((agent_id, current_virt, current_phys, flags));
        }

        // Invalidate TLB for the affected virtual address range for the current CPU.
        // For x86: `invlpg` or `mov cr3, cr3`. For ARM: `dsb ishst`, `isb`.
        Self::flush_tlb();

        Ok(())
    }

    /// Unmaps a previously mapped region.
    pub unsafe fn unmap_region(
        agent_id: u32,
        virt_addr: usize,
        size: usize,
    ) -> Result<(), &'static str> {
        // Similar to map_region, but clears PTEs and flushes TLB.
        core::hint::black_box((agent_id, virt_addr, size));
        Self::flush_tlb();
        Ok(())
    }

    /// Switches the active page table (context) to that of the specified agent.
    /// This is called during agent context switching.
    pub unsafe fn switch_context(agent_id: u32) {
        // For x86: `mov cr3, agent_page_table_base_address`.
        // For ARM: `msr ttbr0_el1, agent_page_table_base_address`.
        // This is a critical, low-latency operation.
        core::hint::black_box(agent_id);
    }

    /// Flushes the Translation Lookaside Buffer (TLB).
    /// Required after modifying page tables to ensure CPU uses new mappings.
    unsafe fn flush_tlb() {
        // Architecture-specific TLB flush instruction.
        // e.g., `asm!("invlpg [{}]", in(reg) addr)` or `asm!("mov %cr3, %cr3")` on x86.
        // For ARM: `asm!("tlbi vmalle1is")`.
        core::hint::black_box(());
    }
}
```

### 1.4 WASM Module Loading and Instantiation

When an AI agent is deployed, its WASM binary is loaded by the AETHER-OS kernel. The kernel then instantiates a new WASM runtime context for it.

```rust
// src/wasm/runtime.rs
#![no_std]

use crate::memory::arena::Arena;
use crate::memory::mmu::{MmuController, MmuFlags};
use core::ptr::NonNull;

// A very simplified WASM module structure for demonstration.
// In reality, a full WASM parser would be needed.
#[repr(C)]
pub struct WasmModule<'a> {
    pub code_start: NonNull<u8>,
    pub code_len: usize,
    pub data_start: NonNull<u8>,
    pub data_len: usize,
    pub initial_memory_pages: u32, // In 64KB pages
    // ... other WASM sections (imports, exports, tables, globals)
    _phantom: core::marker::PhantomData<&'a ()>, // To allow 'a lifetime
}

/// Represents an active WASM instance (an AI agent).
pub struct WasmInstance {
    pub agent_id: u32,
    pub linear_memory_arena: Arena,
    pub linear_memory_virt_base: usize, // Virtual address where WASM linear memory starts
    pub stack_ptr: usize,               // WASM stack pointer
    pub program_counter: usize,         // WASM instruction pointer
    pub module_entry_point: usize,      // Relative offset to the WASM entry function
    // ... other registers/state needed for context switching
}

impl WasmInstance {
    /// Creates and initializes a new WASM instance (agent sandbox).
    /// `agent_id`: Unique identifier for the agent.
    /// `module`: The parsed WASM module definition.
    /// `physical_memory_base`: Base physical address for the agent's linear memory.
    /// `virtual_memory_base`: Base virtual address where the agent's linear memory will be mapped.
    pub unsafe fn new(
        agent_id: u32,
        module: &WasmModule,
        physical_memory_base: *mut u8,
        virtual_memory_base: usize,
    ) -> Result<Self, &'static str> {
        let linear_memory_size = (module.initial_memory_pages as usize) * 64 * 1024; // 64KB pages

        if linear_memory_size == 0 {
            return Err("WASM module must have at least one memory page.");
        }

        // 1. Allocate and manage the WASM linear memory arena.
        let mut linear_memory_arena = Arena::new(physical_memory_base, linear_memory_size);

        // 2. Map the physical memory into the agent's virtual address space using MMU.
        // The WASM linear memory is typically read/write, non-executable.
        MmuController::map_region(
            agent_id,
            virtual_memory_base,
            physical_memory_base as usize,
            linear_memory_size,
            MmuFlags::WASM_LINEAR_MEMORY,
        )?;

        // 3. Copy initial data segments from the module into the linear memory.
        if module.data_len > 0 {
            let data_dest_ptr = (virtual_memory_base as *mut u8);
            ptr::copy_nonoverlapping(
                module.data_start.as_ptr(),
                data_dest_ptr,
                module.data_len,
            );
        }

        // 4. Map WASM code segment (read-only, executable).
        // This assumes the WASM code has been AOT-compiled into native code
        // and placed in a separate physical memory region.
        // For simplicity here, we assume the code is also part of `physical_memory_base`
        // but mapped separately with executable flags.
        // In a real system, the compiled native code would be in a separate, dedicated region.
        MmuController::map_region(
            agent_id,
            virtual_memory_base + linear_memory_size, // Code starts after linear memory
            module.code_start.as_ptr() as usize,
            module.code_len,
            MmuFlags::WASM_CODE_MEMORY,
        )?;

        // 5. Initialize WASM stack pointer (grows downwards from end of linear memory).
        let stack_ptr = virtual_memory_base + linear_memory_size - 4; // Or a dedicated stack region

        Ok(Self {
            agent_id,
            linear_memory_arena,
            linear_memory_virt_base: virtual_memory_base,
            stack_ptr,
            program_counter: virtual_memory_base + linear_memory_size, // Start of mapped code
            module_entry_point: 0, // Placeholder, would be resolved from WASM exports
        })
    }

    /// Executes the WASM instance for a given time slice.
    /// This function would internally call the AETHER-EE (Execution Engine).
    pub unsafe fn execute(&mut self, time_slice_ns: u64) {
        // In a real scenario, this would involve:
        // 1. Switching MMU context to `self.agent_id`.
        // 2. Restoring CPU registers from `self`.
        // 3. Jumping to `self.program_counter`.
        // 4. The AETHER-EE (native code) would run until:
        //    a. It completes its task.
        //    b. It calls a host function.
        //    c. A timer interrupt triggers preemption.
        // 5. Saving CPU registers back into `self` on return.

        // Placeholder: simulate execution
        core::hint::black_box((self, time_slice_ns));
        // Update program_counter and stack_ptr based on simulated execution
        self.program_counter += 10; // Simulate progress
        self.stack_ptr -= 8; // Simulate stack usage
    }

    /// Cleans up the WASM instance.
    pub unsafe fn destroy(&mut self) -> Result<(), &'static str> {
        let linear_memory_size = self.linear_memory_arena.size();
        MmuController::unmap_region(
            self.agent_id,
            self.linear_memory_virt_base,
            linear_memory_size,
        )?;
        // Also unmap code region if separate.
        Ok(())
    }
}
```

### 1.5 Preemptive Execution Interruption and Context Preservation

Preemption is critical for deterministic scheduling and resource fairness. AETHER-OS uses a hardware timer interrupt to periodically interrupt running WASM agents. When an interrupt occurs, the CPU's context (registers, stack pointer, program counter, flags) is saved by the kernel's interrupt handler.

The saved context, along with the WASM linear memory base and other WASM-specific state, constitutes the `WasmInstance`'s full execution state. This state is then stored, and the scheduler selects the next agent to run.

```rust
// src/kernel/interrupts.rs (Conceptual, highly architecture-specific)
#![no_std]

use crate::wasm::runtime::WasmInstance;
use crate::scheduler; // Assume a scheduler module exists

/// Represents the CPU state (subset of registers) saved on context switch.
/// This structure is highly dependent on the target architecture (x86-64, ARM, RISC-V).
/// For x86-64, this would include general-purpose registers (RAX, RBX, RCX, RDX, RSI, RDI, RBP, RSP, R8-R15),
/// segment registers, RFLAGS, and RIP.
#[repr(C)] // Ensure C-compatible layout for assembly interaction
pub struct CpuContext {
    // General-purpose registers
    pub r15: usize,
    pub r14: usize,
    pub r13: usize,
    pub r12: usize,
    pub r11: usize,
    pub r10: usize,
    pub r9: usize,
    pub r8: usize,
    pub rbp: usize,
    pub rsi: usize,
    pub rdi: usize,
    pub rdx: usize,
    pub rcx: usize,
    pub rbx: usize,
    pub rax: usize,
    // Stack pointer (pushed by interrupt handler or manually)
    pub rsp: usize,
    // Flags register
    pub rflags: usize,
    // Instruction pointer
    pub rip: usize,
    // Segment registers, etc. (omitted for brevity)
}

/// A global mutable reference to the currently executing WASM instance.
/// This would typically be managed by the scheduler.
static mut CURRENT_WASM_INSTANCE: Option<&'static mut WasmInstance> = None;

/// The main timer interrupt handler.
/// This function is called by the low-level assembly interrupt dispatcher.
#[no_mangle] // Prevent Rust from mangling the name for assembly linkage
pub extern "C" fn timer_interrupt_handler(cpu_context: &mut CpuContext) {
    // 1. Save WASM-specific state (program counter, stack pointer) from CPU_CONTEXT
    //    into the currently running WasmInstance.
    //    This requires `CURRENT_WASM_INSTANCE` to be safely managed (e.g., through a scheduler lock).
    unsafe {
        if let Some(instance) = CURRENT_WASM_INSTANCE.as_mut() {
            instance.program_counter = cpu_context.rip;
            instance.stack_ptr = cpu_context.rsp; // The RSP *before* the interrupt stack frame
                                                   // Other WASM-specific state (e.g., WASM stack, locals)
                                                   // would be managed by the AETHER-EE and saved/restored there.
        }
    }

    // 2. Acknowledge the interrupt controller (e.g., PIC, APIC, GIC).
    //    This prevents the interrupt from firing again immediately.
    //    `PIC_CONTROLLER.end_of_interrupt();`

    // 3. Invoke the scheduler to choose the next agent to run.
    let next_instance = scheduler::schedule_next_agent();

    // 4. Restore CPU state from the `next_instance` into `cpu_context`.
    unsafe {
        if let Some(instance) = next_instance {
            cpu_context.rip = instance.program_counter;
            cpu_context.rsp = instance.stack_ptr;
            // Update CURRENT_WASM_INSTANCE
            CURRENT_WASM_INSTANCE = Some(instance);

            // Switch MMU context to the new agent's page table.
            // This is crucial for memory isolation.
            // MmuController::switch_context(instance.agent_id);
        } else {
            // No agents to run, halt or yield to idle task.
            // For now, simply return and resume previous (or halt).
            // A real kernel would have an idle loop.
        }
    }
}

// Low-level assembly stub for timer interrupt entry.
// This pushes registers, calls `timer_interrupt_handler`, then pops and returns.
// Example for x86-64 (simplified):
/*
.global _start_timer_interrupt
_start_timer_interrupt:
    ; Save general-purpose registers
    push rax
    push rbx
    ; ... push all other relevant registers ...
    ; Push RSP (or calculate it from current stack frame)
    ; Push RFLAGS
    ; Push RIP (already pushed by CPU for interrupt)

    ; Move stack pointer to align for C function call
    ; mov rdi, rsp ; Pass &CpuContext to timer_interrupt_handler

    ; call timer_interrupt_handler

    ; Restore registers
    ; pop rflags
    ; pop rip (iretq will do this)
    ; ... pop all other registers ...
    iretq ; Return from interrupt
*/
```

### 1.6 Rust Implementation: AETHER-WASM Memory Manager

Combining the `Arena` and MMU concepts, here's a more integrated view of the WASM memory manager within AETHER-OS. This component manages the lifecycle of WASM linear memory.

```rust
// src/wasm/mem_manager.rs
#![no_std]

use crate::memory::arena::Arena;
use crate::memory::mmu::{MmuController, MmuFlags};
use core::ptr::NonNull;

/// Size of a WASM page (64KB).
pub const WASM_PAGE_SIZE: usize = 64 * 1024;

/// Manages WASM linear memory for all agents.
pub struct WasmMemoryManager {
    // In a real system, this would manage a pool of physical memory
    // and assign chunks to agents. For simplicity, we assume `get_physical_memory_block`
    // provides raw physical memory.
    next_agent_virt_base: usize, // Next available virtual address for an agent's linear memory
    next_agent_id: u32,
}

impl WasmMemoryManager {
    /// Initializes the WASM memory manager.
    pub fn new(initial_virtual_address_space_start: usize) -> Self {
        Self {
            next_agent_virt_base: initial_virtual_address_space_start,
            next_agent_id: 0,
        }
    }

    /// Allocates and initializes linear memory for a new WASM agent.
    /// Returns the assigned agent_id and the initialized Arena.
    pub unsafe fn create_agent_memory(
        &mut self,
        initial_pages: u32,
        max_pages: u32, // WASM max memory limit
    ) -> Result<(u32, Arena, usize), &'static str> {
        let agent_id = self.next_agent_id;
        self.next_agent_id += 1;

        let initial_size = (initial_pages as usize) * WASM_PAGE_SIZE;
        let max_size = (max_pages as usize) * WASM_PAGE_SIZE;

        if initial_size == 0 || initial_size > max_size {
            return Err("Invalid WASM memory size configuration.");
        }

        // 1. Obtain a raw physical memory block from the kernel's physical allocator.
        //    This function is conceptual, assuming it returns a sufficiently large block.
        //    In a real kernel, this would involve `buddy_allocator.alloc_pages(num_pages)`.
        let physical_mem_ptr = self.get_physical_memory_block(max_size)?;

        // 2. Assign a virtual address base for this agent's linear memory.
        //    Each agent gets its own distinct virtual address range.
        let agent_virt_base = self.next_agent_virt_base;
        self.next_agent_virt_base += max_size; // Advance for next agent

        // 3. Create the Arena, which will manage allocations within this physical block.
        let mut arena = Arena::new(physical_mem_ptr, max_size);

        // 4. Map the initial memory pages into the agent's virtual address space.
        //    We map the *maximum* allowed memory for the agent, but only `initial_size`
        //    is immediately available to the WASM module. The rest can be grown into.
        MmuController::map_region(
            agent_id,
            agent_virt_base,
            physical_mem_ptr as usize,
            max_size, // Map the full potential size
            MmuFlags::WASM_LINEAR_MEMORY,
        )?;

        Ok((agent_id, arena, agent_virt_base))
    }

    /// Grows an agent's linear memory by `delta_pages`.
    /// This requires updating the WASM instance's internal memory bounds
    /// and potentially adjusting MMU mappings if `max_pages` was not fully mapped initially.
    pub unsafe fn grow_agent_memory(
        &mut self,
        agent_id: u32,
        current_arena: &mut Arena,
        delta_pages: u32,
    ) -> Result<(), &'static str> {
        let delta_size = (delta_pages as usize) * WASM_PAGE_SIZE;
        let new_size = current_arena.size() + delta_size;

        // In a simple arena, growing means checking if `new_size` is within the
        // pre-allocated `max_size` region. If it exceeds, a re-allocation
        // (moving the arena) would be necessary, which is complex for `no_std`
        // and usually avoided for linear memory.
        // For AETHER-OS, we pre-map `max_size` so growth is just a logical update.

        // Update the logical size of the arena.
        // current_arena.resize(new_size); // Conceptual resize, Arena doesn't directly support this.
        // The MMU mapping is already for `max_size`, so no MMU update needed.
        // This means the `Arena` struct might need to track `current_logical_size` vs `physical_capacity`.

        core::hint::black_box((agent_id, current_arena, delta_pages, new_size));
        Ok(())
    }

    /// Deallocates an agent's linear memory.
    pub unsafe fn destroy_agent_memory(
        &mut self,
        agent_id: u32,
        arena: Arena,
        virt_base: usize,
    ) -> Result<(), &'static str> {
        let size = arena.size();
        MmuController::unmap_region(agent_id, virt_base, size)?;

        // Return the physical memory block to the kernel's physical allocator.
        self.return_physical_memory_block(arena.base(), size)?;

        Ok(())
    }

    /// Conceptual function to get a physical memory block.
    /// In a real kernel, this would interface with a physical page allocator.
    unsafe fn get_physical_memory_block(&self, size: usize) -> Result<*mut u8, &'static str> {
        // Placeholder: return a fixed address for demonstration.
        // In reality, this would be a call to a kernel physical memory allocator.
        // Ensure the returned address is page-aligned.
        let ptr = 0x8000_0000 as *mut u8; // Example physical address
        if size > (1024 * 1024 * 1024) { // Arbitrary limit
            return Err("Requested memory block too large.");
        }
        Ok(ptr)
    }

    /// Conceptual function to return a physical memory block.
    unsafe fn return_physical_memory_block(&self, _ptr: *mut u8, _size: usize) -> Result<(), &'static str> {
        // Placeholder: In reality, return to physical page allocator.
        Ok(())
    }
}
```

This chapter has laid the groundwork for secure, high-performance WASM agent execution within AETHER-OS, focusing on the critical aspects of `no_std` memory management, hardware-assisted isolation, and preemption. The next chapter will build on this foundation by enabling zero-copy, high-throughput communication between these isolated agents using GPU resources.

---

## Chapter 2: Zero-Copy GPU IPC & Unified Memory Virtualization

### 2.1 The Bottleneck of Data Movement in Multi-Agent AI

Autonomous AI agent swarms are inherently data-intensive. Agents often need to share large contextual information, such as embeddings, LLM states, sensor fusion data, or environmental maps. In GPU-accelerated environments, this data frequently resides in GPU memory. The traditional approach of copying data between CPU host memory and GPU device memory, or even between different GPU device memory regions associated with distinct processes, introduces significant latency and consumes precious PCI-e bandwidth. For AETHER-OS's zero-latency mandate, this is an unacceptable bottleneck.

The goal of this chapter is to enable direct, zero-copy inter-process communication (IPC) for large tensor buffers, specifically focusing on LLM context sharing. This means that data produced by one agent's GPU kernel can be directly consumed by another agent's GPU kernel without any intermediate copies, either to host memory or to another device memory location.

### 2.2 NVIDIA Unified Memory (UM) as the Foundation

NVIDIA's Unified Memory (UM) is a cornerstone technology for achieving zero-copy data sharing. UM provides a single, coherent memory address space accessible by both the CPU and the GPU. The NVIDIA driver and hardware transparently manage data migration between CPU and GPU memory as needed, based on access patterns.

While UM simplifies programming by abstracting data movement, for true zero-copy IPC between *isolated processes* (our WASM sandboxes, each with its own CUDA context), we need more explicit control. UM, in conjunction with CUDA IPC primitives, allows multiple CUDA contexts to map and access the *same physical memory pages*, thereby eliminating data copies.

Key benefits of UM for AETHER-OS:
*   **Simplified Memory Management:** Agents can allocate memory that is conceptually shared, without needing to explicitly `cudaMalloc` and `cudaMemcpy`.
*   **Reduced CPU-GPU Latency:** Data is migrated on demand, often reducing explicit copies.
*   **Foundation for GPU IPC:** UM-allocated memory can be exported and imported as IPC handles, allowing different CUDA contexts to access it directly.

### 2.3 GPU Inter-Process Communication (IPC) for Tensor Sharing

CUDA provides specific APIs for inter-process communication that allow distinct CUDA contexts (associated with different processes or WASM sandboxes in our case) to share memory. The core mechanism involves a "producer" CUDA context exporting a memory handle, and a "consumer" CUDA context importing that handle to map the shared memory into its own address space.

#### 2.3.1 Producer-Consumer Model with IPC Handles

The workflow for zero-copy GPU IPC is as follows:

1.  **Producer Agent:**
    *   Allocates a buffer in GPU memory (or Unified Memory).
    *   Writes its LLM context (e.g., attention keys/values, hidden states) into this buffer using a CUDA kernel.
    *   Obtains an IPC handle to this buffer using `cudaIpcGetMemHandle()`.
    *   Sends this handle (a small, serializable data structure) to the Consumer Agent via an AETHER-OS kernel IPC mechanism (e.g., a message queue or shared kernel buffer).

2.  **Consumer Agent:**
    *   Receives the IPC handle from the AETHER-OS kernel.
    *   Imports the memory using `cudaIpcOpenMemHandle()`, which maps the shared buffer into its own CUDA context's address space.
    *   Accesses the shared buffer directly from its CUDA kernels.
    *   When done, closes the handle with `cudaIpcCloseMemHandle()`.

#### 2.3.2 Ensuring Memory Coherency and Access Control

While zero-copy is achieved, challenges remain:
*   **Coherency:** If both producer and consumer might write to the same memory, careful synchronization (e.g., CUDA events, fences) is required to ensure data visibility and prevent race conditions. For LLM context sharing, it's often a producer-writes-consumer-reads model, simplifying coherency.
*   **Access Control:** AETHER-OS must ensure that only authorized agents can receive and open IPC handles. The kernel acts as a trusted intermediary, validating requests before forwarding handles.
*   **Lifetime Management:** The producer must ensure the underlying memory remains valid until all consumers have finished with it. Reference counting or explicit signaling through the AETHER-OS kernel is necessary.

### 2.4 Virtualizing GPU Memory for Isolated Sandboxes

Each WASM sandbox, when it needs GPU access, will have its own CUDA context. AETHER-OS orchestrates these contexts. When a WASM agent requests GPU memory, AETHER-OS:

1.  Determines the agent's GPU resource limits.
2.  Allocates memory using `cudaMallocManaged` (for UM) or `cudaMalloc` within the agent's dedicated CUDA context.
3.  Manages the lifecycle of these allocations, associating them with the `WasmInstance`.
4.  Provides a secure mechanism for agents to request IPC handles for their allocated GPU buffers and to open handles received from other agents. This mechanism will be exposed as a host function (WASI-Lite API) that WASM agents can call.

### 2.5 CUDA C++ Kernel and Rust FFI Bridge Implementation

We will demonstrate the core IPC mechanism with a simple CUDA C++ producer and consumer kernel, and then show how AETHER-OS (written in Rust) bridges to these CUDA capabilities via Foreign Function Interface (FFI).

#### 2.5.1 CUDA Producer Kernel

This kernel will allocate unified memory, populate it with a tensor (e.g., a simulated LLM context vector), and then obtain an IPC handle.

```cpp
// src/gpu/cuda_producer.cu
#include <cuda_runtime.h>
#include <cuda_fp16.h> // For half-precision floats, common in AI
#include <cstdio>
#include <cstring> // For memset

#define CHECK_CUDA(call) \
    do { \
        cudaError_t err = call; \
        if (err != cudaSuccess) { \
            fprintf(stderr, "CUDA error in %s:%d - %s\n", __FILE__, __LINE__, cudaGetErrorString(err)); \
            return err; \
        } \
    } while (0)

// Define a simple tensor structure for context sharing
struct LLMContextTensor {
    __half data[4096]; // Example: 4096 half-precision floats (8KB)
    int agent_id;
    long long timestamp;
};

// Kernel to populate the LLMContextTensor
__global__ void populateLLMContext(LLMContextTensor* tensor, int id, long long ts) {
    // Each thread can write a part of the tensor if it's larger
    // For simplicity, we'll just set the first element and metadata
    if (threadIdx.x == 0) {
        tensor->agent_id = id;
        tensor->timestamp = ts;
        for (int i = 0; i < 4096; ++i) {
            tensor->data[i] = (__half)(id * 0.1f + i * 0.001f);
        }
    }
}

extern "C" {
    /// Allocates Unified Memory for an LLMContextTensor and populates it.
    /// Returns a cudaIpcMemHandle_t via `ipc_handle_out`.
    /// `agent_id`: The ID of the producing agent.
    /// `tensor_ptr_out`: Pointer to store the device pointer of the allocated tensor.
    /// Returns cudaSuccess on success, or an error code.
    cudaError_t allocate_and_populate_llm_context(
        int agent_id,
        cudaIpcMemHandle_t* ipc_handle_out,
        LLMContextTensor** tensor_ptr_out // For direct access from producer, if needed
    ) {
        LLMContextTensor* d_tensor;
        size_t size = sizeof(LLMContextTensor);

        // Allocate Unified Memory
        CHECK_CUDA(cudaMallocManaged(&d_tensor, size, cudaMemAttachGlobal));
        CHECK_CUDA(cudaMemset(d_tensor, 0, size)); // Initialize to zero

        // Launch kernel to populate the tensor
        populateLLMContext<<<1, 1>>>(d_tensor, agent_id, cudaGetSurfaceReferenceFlags()); // Using current timestamp as example
        CHECK_CUDA(cudaGetLastError()); // Check for kernel launch errors
        CHECK_CUDA(cudaDeviceSynchronize()); // Ensure kernel completes before getting handle

        // Get IPC handle
        CHECK_CUDA(cudaIpcGetMemHandle(ipc_handle_out, d_tensor));

        *tensor_ptr_out = d_tensor; // Return the device pointer for producer's use

        return cudaSuccess;
    }

    /// Frees the Unified Memory allocated by the producer.
    cudaError_t free_llm_context(LLMContextTensor* d_tensor) {
        CHECK_CUDA(cudaFree(d_tensor));
        return cudaSuccess;
    }
}
```

#### 2.5.2 CUDA Consumer Kernel

This kernel will open an IPC handle received from a producer, map the shared memory, and then read from it.

```cpp
// src/gpu/cuda_consumer.cu
#include <cuda_runtime.h>
#include <cuda_fp16.h>
#include <cstdio>

#define CHECK_CUDA(call) \
    do { \
        cudaError_t err = call; \
        if (err != cudaSuccess) { \
            fprintf(stderr, "CUDA error in %s:%d - %s\n", __FILE__, __LINE__, cudaGetErrorString(err)); \
            return err; \
        } \
    } while (0)

// Re-declare the tensor structure (must match producer)
struct LLMContextTensor {
    __half data[4096];
    int agent_id;
    long long timestamp;
};

// Kernel to read and process the LLMContextTensor
__global__ void processLLMContext(LLMContextTensor* tensor, int consumer_agent_id) {
    if (threadIdx.x == 0) {
        printf("Consumer Agent %d received context from Producer Agent %d (Timestamp: %lld)\n",
               consumer_agent_id, tensor->agent_id, tensor->timestamp);
        // Example: access some data
        if (tensor->data[0] == (__half)(tensor->agent_id * 0.1f)) {
            printf("  Data integrity check passed for data[0]!\n");
        } else {
            printf("  Data integrity check FAILED for data[0]!\n");
        }
        // Potentially perform further LLM operations, e.g., attention, feed-forward
    }
}

extern "C" {
    /// Opens an IPC handle, maps the shared memory, and processes it with a kernel.
    /// `ipc_handle`: The handle received from the producer.
    /// `consumer_agent_id`: The ID of the consuming agent.
    /// `d_tensor_out`: Pointer to store the device pointer of the mapped tensor (for closing).
    /// Returns cudaSuccess on success, or an error code.
    cudaError_t open_and_process_llm_context(
        cudaIpcMemHandle_t ipc_handle,
        int consumer_agent_id,
        LLMContextTensor** d_tensor_out
    ) {
        LLMContextTensor* d_tensor;
        // Open the IPC handle and map the memory into this CUDA context
        CHECK_CUDA(cudaIpcOpenMemHandle((void**)&d_tensor, ipc_handle, cudaIpcMemLazyEnablePeerAccess));

        // Launch kernel to process the tensor
        processLLMContext<<<1, 1>>>(d_tensor, consumer_agent_id);
        CHECK_CUDA(cudaGetLastError()); // Check for kernel launch errors
        CHECK_CUDA(cudaDeviceSynchronize()); // Ensure kernel completes

        *d_tensor_out = d_tensor; // Return the device pointer for later closing

        return cudaSuccess;
    }

    /// Closes the shared memory handle.
    cudaError_t close_llm_context(LLMContextTensor* d_tensor) {
        CHECK_CUDA(cudaIpcCloseMemHandle(d_tensor));
        return cudaSuccess;
    }
}
```

#### 2.5.3 Rust FFI Bridge for IPC Management

AETHER-OS, implemented in Rust, will provide the interface for WASM agents to interact with these CUDA kernels. This involves defining the FFI bindings and handling the `cudaIpcMemHandle_t` opaque type.

```rust
// src/gpu/ffi.rs
#![allow(non_camel_case_types)] // Allow C-style type names for FFI
#![no_std]

use core::ffi::c_int;

// Opaque type for cudaError_t
#[repr(transparent)]
pub struct cudaError_t(c_int);

impl cudaError_t {
    pub const cudaSuccess: cudaError_t = cudaError_t(0);

    pub fn is_success(&self) -> bool {
        self.0 == Self::cudaSuccess.0
    }
}

// Opaque type for cudaIpcMemHandle_t
// This is a struct of fixed size, often 64 bytes for NVIDIA.
// We represent it as a byte array for FFI.
#[repr(C)]
pub struct cudaIpcMemHandle_t {
    pub reserved: [u8; 64], // Size is implementation-defined by CUDA
}

// Struct for LLMContextTensor, must match C++ definition
#[repr(C)]
pub struct LLMContextTensor {
    // Assuming __half is 2 bytes. Adjust if using float for simplicity.
    pub data: [u16; 4096], // Rust's u16 can represent __half, or use `half` crate.
    pub agent_id: c_int,
    pub timestamp: i64,
}

extern "C" {
    // Producer functions
    pub fn allocate_and_populate_llm_context(
        agent_id: c_int,
        ipc_handle_out: *mut cudaIpcMemHandle_t,
        tensor_ptr_out: *mut *mut LLMContextTensor,
    ) -> cudaError_t;

    pub fn free_llm_context(d_tensor: *mut LLMContextTensor) -> cudaError_t;

    // Consumer functions
    pub fn open_and_process_llm_context(
        ipc_handle: cudaIpcMemHandle_t,
        consumer_agent_id: c_int,
        d_tensor_out: *mut *mut LLMContextTensor,
    ) -> cudaError_t;

    pub fn close_llm_context(d_tensor: *mut LLMContextTensor) -> cudaError_t;
}

// src/gpu/mod.rs (AETHER-OS GPU module)
#![no_std]

use crate::gpu::ffi::{cudaError_t, cudaIpcMemHandle_t, LLMContextTensor};
use core::ptr;

/// A wrapper for an allocated LLMContextTensor on the GPU, with its IPC handle.
pub struct GpuContextHandle {
    pub ipc_handle: cudaIpcMemHandle_t,
    pub device_ptr: *mut LLMContextTensor, // The device pointer for the producer's context
    pub agent_id: u32,
}

impl GpuContextHandle {
    /// Creates a new LLM context on the GPU and gets its IPC handle.
    pub unsafe fn new_producer_context(agent_id: u32) -> Result<Self, &'static str> {
        let mut ipc_handle = cudaIpcMemHandle_t { reserved: [0; 64] };
        let mut device_ptr: *mut LLMContextTensor = ptr::null_mut();

        let cuda_err = ffi::allocate_and_populate_llm_context(
            agent_id as c_int,
            &mut ipc_handle,
            &mut device_ptr,
        );

        if cuda_err.is_success() {
            Ok(Self {
                ipc_handle,
                device_ptr,
                agent_id,
            })
        } else {
            Err("Failed to allocate and populate LLM context on GPU.")
        }
    }

    /// Releases the GPU memory associated with this handle.
    pub unsafe fn free(self) -> Result<(), &'static str> {
        let cuda_err = ffi::free_llm_context(self.device_ptr);
        if cuda_err.is_success() {
            Ok(())
        } else {
            Err("Failed to free LLM context on GPU.")
        }
    }
}

/// A wrapper for a consumed LLMContextTensor.
pub struct GpuConsumedContext {
    pub device_ptr: *mut LLMContextTensor, // The device pointer for the consumer's context
    pub consumer_agent_id: u32,
}

impl GpuConsumedContext {
    /// Opens an IPC handle and processes the shared LLM context.
    pub unsafe fn open_and_process(
        ipc_handle: cudaIpcMemHandle_t,
        consumer_agent_id: u32,
    ) -> Result<Self, &'static str> {
        let mut device_ptr: *mut LLMContextTensor = ptr::null_mut();

        let cuda_err = ffi::open_and_process_llm_context(
            ipc_handle,
            consumer_agent_id as c_int,
            &mut device_ptr,
        );

        if cuda_err.is_success() {
            Ok(Self {
                device_ptr,
                consumer_agent_id,
            })
        } else {
            Err("Failed to open and process LLM context on GPU.")
        }
    }

    /// Closes the shared memory handle.
    pub unsafe fn close(self) -> Result<(), &'static str> {
        let cuda_err = ffi::close_llm_context(self.device_ptr);
        if cuda_err.is_success() {
            Ok(())
        } else {
            Err("Failed to close LLM context on GPU.")
        }
    }
}

// Example usage within AETHER-OS kernel or a host function for WASM agents:
/*
pub unsafe fn agent_gpu_ipc_example() {
    // Agent 1 (Producer)
    let producer_agent_id = 101;
    let producer_handle = GpuContextHandle::new_producer_context(producer_agent_id)
        .expect("Producer failed");

    // Simulate sending `producer_handle.ipc_handle` to Agent 2 via AETHER-OS IPC
    // ...

    // Agent 2 (Consumer)
    let consumer_agent_id = 102;
    let consumer_context = GpuConsumedContext::open_and_process(
        producer_handle.ipc_handle,
        consumer_agent_id,
    ).expect("Consumer failed");

    // Consumer is done with the context
    consumer_context.close().expect("Consumer failed to close");

    // Producer is done and can free its original allocation
    producer_handle.free().expect("Producer failed to free");

    crate::println!("GPU IPC example completed.");
}
*/
```

This chapter has provided a robust framework for zero-copy GPU IPC, leveraging NVIDIA Unified Memory and CUDA IPC primitives, all orchestrated by the AETHER-OS kernel through a Rust FFI. This mechanism is crucial for enabling high-throughput data sharing among autonomous AI agents without incurring performance penalties from data movement. The next chapter will delve into the critical aspects of scheduling these agents and maintaining consistent state across the swarm.

---

## Chapter 3: Deterministic Swarm Scheduler & Vector Clock Consensus

### 3.1 Orchestrating Agent Swarms: The Need for Determinism

Managing a swarm of autonomous AI agents demands a scheduler that goes beyond traditional OS process scheduling. For AETHER-OS, determinism is paramount. In critical AI applications, the exact sequence of events and state transitions must be reproducible and predictable. This is essential for debugging, validation, and ensuring the reliability of emergent swarm behaviors. A non-deterministic scheduler can lead to subtle, hard-to-trace bugs and inconsistent outcomes.

The AETHER-OS scheduler must handle:
*   **Preemptive Execution:** Fairly distributing CPU (and GPU) time among agents.
*   **Zero-Latency Context Switching:** Minimizing the overhead of switching between agent execution contexts.
*   **Deadlock Resolution:** Proactively preventing or efficiently resolving resource contention among agents.
*   **State Synchronization:** Ensuring that shared knowledge and cooperative decision-making are based on a consistent view of the swarm's state, even in a distributed, asynchronous environment.

### 3.2 AETHER-OS Preemptive Round-Robin Agent Scheduler

A preemptive Round-Robin scheduler is chosen for its simplicity, fairness, and predictability. Each agent is allocated a fixed time slice (quantum), and upon expiration, the current agent is preempted, its context saved, and the next agent in the ready queue is dispatched.

#### 3.2.1 Agent Control Blocks (ACBs) and Context Switching

Each active WASM agent is represented by an **Agent Control Block (ACB)** within the AETHER-OS kernel. The ACB encapsulates all the necessary state to save and restore an agent's execution.

```rust
// src/scheduler/acb.rs
#![no_std]

use crate::wasm::runtime::WasmInstance;
use crate::memory::mmu::MmuController;
use core::ptr;

/// Represents the full execution context of an AI agent (WASM instance).
/// This includes CPU registers and WASM runtime-specific state.
#[repr(C)] // Ensure C-compatible layout for assembly interaction
pub struct AgentContext {
    // CPU registers (subset of general-purpose, stack, instruction pointers, flags)
    // Ordered for efficient pushing/popping by assembly context switch routines.
    pub r15: usize, pub r14: usize, pub r13: usize, pub r12: usize,
    pub r11: usize, pub r10: usize, pub r9: usize,  pub r8: usize,
    pub rbp: usize, pub rsi: usize, pub rdi: usize, pub rdx: usize,
    pub rcx: usize, pub rbx: usize, pub rax: usize,
    pub rsp: usize, // Stack pointer
    pub rflags: usize, // CPU flags
    pub rip: usize, // Instruction pointer

    // WASM instance specific state
    // We embed the WasmInstance here or hold a reference to it.
    // For simplicity, let's assume `WasmInstance` itself contains the core state.
    pub wasm_instance_state: WasmInstance,
    pub agent_id: u32,
    pub status: AgentStatus,
    pub priority: u8,
    pub time_slice_ns: u64, // Remaining time slice
    pub last_scheduled_time: u64, // For statistics/debugging
    // ... other scheduling metadata (e.g., resource usage, next_ready_link)
}

/// Agent execution status.
#[derive(Debug, PartialEq, Eq, Copy, Clone)]
#[repr(u8)]
pub enum AgentStatus {
    Ready,      // Waiting to be scheduled
    Running,    // Currently executing
    Blocked,    // Waiting for a resource/event
    Terminated, // Finished execution
    Sleeping,   // Temporarily paused
}

impl AgentContext {
    /// Creates a new AgentContext from a WasmInstance.
    /// This is the initial setup for an agent.
    pub fn new(wasm_instance: WasmInstance, priority: u8, time_slice_ns: u64) -> Self {
        AgentContext {
            // Initialize CPU registers for the first run.
            // These would point to the WASM entry point and stack.
            r15: 0, r14: 0, r13: 0, r12: 0,
            r11: 0, r10: 0, r9: 0, r8: 0,
            rbp: 0, rsi: 0, rdi: 0, rdx: 0,
            rcx: 0, rbx: 0, rax: 0,
            rsp: wasm_instance.stack_ptr, // WASM stack pointer
            rflags: 0x202, // Enable interrupts (IF bit) for x86-64
            rip: wasm_instance.program_counter, // WASM entry point
            wasm_instance_state: wasm_instance,
            agent_id: wasm_instance.agent_id,
            status: AgentStatus::Ready,
            priority,
            time_slice_ns,
            last_scheduled_time: 0,
        }
    }

    /// Saves the current CPU context into the AgentContext.
    /// This function would typically be called from assembly after an interrupt.
    /// It's unsafe because it directly manipulates raw pointers and CPU state.
    pub unsafe fn save_cpu_context(&mut self, cpu_context_ptr: *const CpuContext) {
        let saved_context = &*cpu_context_ptr;
        self.r15 = saved_context.r15; self.r14 = saved_context.r14; self.r13 = saved_context.r13; self.r12 = saved_context.r12;
        self.r11 = saved_context.r11; self.r10 = saved_context.r10; self.r9 = saved_context.r9;  self.r8 = saved_context.r8;
        self.rbp = saved_context.rbp; self.rsi = saved_context.rsi; self.rdi = saved_context.rdi; self.rdx = saved_context.rdx;
        self.rcx = saved_context.rcx; self.rbx = saved_context.rbx; self.rax = saved_context.rax;
        self.rsp = saved_context.rsp;
        self.rflags = saved_context.rflags;
        self.rip = saved_context.rip;

        // Also update WASM instance state if it's separate from CPU registers
        self.wasm_instance_state.program_counter = saved_context.rip;
        self.wasm_instance_state.stack_ptr = saved_context.rsp;
    }

    /// Restores the CPU context from the AgentContext.
    /// This function would prepare the stack for an `iretq` (x86-64) or equivalent.
    /// It's unsafe.
    pub unsafe fn restore_cpu_context(&self, cpu_context_ptr: *mut CpuContext) {
        let restored_context = &mut *cpu_context_ptr;
        restored_context.r15 = self.r15; restored_context.r14 = self.r14; restored_context.r13 = self.r13; restored_context.r12 = self.r12;
        restored_context.r11 = self.r11; restored_context.r10 = self.r10; restored_context.r9 = self.r9;  restored_context.r8 = self.r8;
        restored_context.rbp = self.rbp; restored_context.rsi = self.rsi; restored_context.rdi = self.rdi; restored_context.rdx = self.rdx;
        restored_context.rcx = self.rcx; restored_context.rbx = self.rbx; restored_context.rax = self.rax;
        restored_context.rsp = self.rsp;
        restored_context.rflags = self.rflags;
        restored_context.rip = self.rip;

        // Switch the MMU context for this agent.
        MmuController::switch_context(self.agent_id);
    }
}

// Minimal CpuContext struct for FFI/assembly interaction, as seen in Chapter 1.
// This is the structure that the assembly interrupt handler would push/pop.
#[repr(C)]
pub struct CpuContext {
    pub r15: usize, pub r14: usize, pub r13: usize, pub r12: usize,
    pub r11: usize, pub r10: usize, pub r9: usize,  pub r8: usize,
    pub rbp: usize, pub rsi: usize, pub rdi: usize, pub rdx: usize,
    pub rcx: usize, pub rbx: usize, pub rax: usize,
    pub rsp: usize,
    pub rflags: usize,
    pub rip: usize,
}
```

#### 3.2.2 Time Slicing and Quantum Management

The scheduler uses a hardware timer (e.g., APIC timer on x86, ARM system timer) to generate periodic interrupts. Each interrupt signals the end of a time quantum for the currently running agent.

```rust
// src/scheduler/mod.rs
#![no_std]

use crate::scheduler::acb::{AgentContext, AgentStatus, CpuContext};
use crate::time; // Assume a time module for current monotonic time
use core::sync::atomic::{AtomicPtr, Ordering};
use core::ptr::NonNull;

/// A simple, `no_std` intrusive linked list for the ready queue.
/// Agents will link themselves into this list.
pub struct AgentLinkedListNode {
    pub next: Option<NonNull<AgentContext>>,
    pub prev: Option<NonNull<AgentContext>>,
}

/// Global scheduler state.
pub struct Scheduler {
    ready_queue_head: Option<NonNull<AgentContext>>,
    ready_queue_tail: Option<NonNull<AgentContext>>,
    current_agent: AtomicPtr<AgentContext>, // Pointer to the currently running agent
    next_agent_id: u32,
    quantum_ns: u64, // Default time slice for agents
}

static mut SCHEDULER: Scheduler = Scheduler {
    ready_queue_head: None,
    ready_queue_tail: None,
    current_agent: AtomicPtr::new(ptr::null_mut()),
    next_agent_id: 0,
    quantum_ns: 10_000_000, // 10ms default quantum
};

impl Scheduler {
    /// Adds an agent to the ready queue.
    pub unsafe fn add_agent(&mut self, mut agent: AgentContext) {
        agent.agent_id = self.next_agent_id;
        self.next_agent_id += 1;
        agent.status = AgentStatus::Ready;

        let agent_ptr = NonNull::new_unchecked(&mut agent as *mut AgentContext);

        if self.ready_queue_head.is_none() {
            self.ready_queue_head = Some(agent_ptr);
            self.ready_queue_tail = Some(agent_ptr);
            // Initialize prev/next for the agent's internal list node (if using intrusive list)
            // agent.next = None; agent.prev = None;
        } else {
            // Append to tail
            let mut tail = self.ready_queue_tail.unwrap().as_mut();
            // tail.next = Some(agent_ptr); // Intrusive list link
            // agent.prev = Some(NonNull::new_unchecked(tail));
            self.ready_queue_tail = Some(agent_ptr);
        }
        // In a real intrusive list, we'd need to link `agent` itself.
        // For simplicity, this acts as a conceptual queue.
        // A `no_std` safe queue implementation would be used here.
        // For now, assume a static array or a more complex `no_std` list.
        // Let's use a simpler conceptual model for `schedule_next_agent`.
        crate::println!("Agent {} added to ready queue.", agent.agent_id);
    }

    /// Called by the timer interrupt handler to schedule the next agent.
    /// Saves the context of the current agent and loads the context of the next.
    /// Returns a mutable reference to the next agent's context, or None if no agents.
    pub unsafe fn schedule_next_agent<'a>(&'a mut self, current_cpu_context: &mut CpuContext) -> Option<&'a mut AgentContext> {
        let current_agent_ptr = self.current_agent.load(Ordering::Acquire);

        if !current_agent_ptr.is_null() {
            let current_agent = &mut *current_agent_ptr;
            current_agent.save_cpu_context(current_cpu_context);
            current_agent.status = AgentStatus::Ready; // Put back in ready queue
            current_agent.time_slice_ns = self.quantum_ns; // Reset quantum
            // In a real round-robin, this agent would be moved to the end of the ready queue.
            // For this conceptual example, we just assume it's available.
        }

        // Simple Round-Robin: pick the next agent from a conceptual list/array.
        // This needs to be a proper queue for actual RR.
        let next_agent_ptr = self.get_next_ready_agent();

        if let Some(next_agent) = next_agent_ptr {
            let next_agent_mut = next_agent.as_mut();
            next_agent_mut.status = AgentStatus::Running;
            next_agent_mut.last_scheduled_time = time::monotonic_time_ns();
            self.current_agent.store(next_agent.as_ptr(), Ordering::Release);
            next_agent_mut.restore_cpu_context(current_cpu_context);
            Some(next_agent_mut)
        } else {
            self.current_agent.store(ptr::null_mut(), Ordering::Release);
            None // No agents to run, maybe an idle task.
        }
    }

    /// Conceptual function to get the next ready agent.
    /// In a real system, this would dequeue from `ready_queue_head` and re-enqueue `current_agent`
    /// at `ready_queue_tail`.
    unsafe fn get_next_ready_agent(&mut self) -> Option<NonNull<AgentContext>> {
        // Placeholder: For a true round-robin, this would involve dequeueing from the head
        // and re-enqueueing the current agent (if not terminated/blocked) at the tail.
        // Since we don't have a full `no_std` queue here, this is illustrative.
        // Let's assume a static array of AgentContexts for now for simple iteration.
        // This is not a proper scheduler, but demonstrates the interaction.
        static mut AGENT_POOL: [Option<AgentContext>; 10] = [None; 10];
        static mut NEXT_AGENT_IDX: usize = 0;

        // Find the next ready agent in the pool
        let start_idx = NEXT_AGENT_IDX;
        loop {
            NEXT_AGENT_IDX = (NEXT_AGENT_IDX + 1) % AGENT_POOL.len();
            if let Some(ref mut agent_ctx) = AGENT_POOL[NEXT_AGENT_IDX] {
                if agent_ctx.status == AgentStatus::Ready {
                    return NonNull::new(agent_ctx as *mut AgentContext);
                }
            }
            if NEXT_AGENT_IDX == start_idx {
                // Looped through all agents, none are ready
                return None;
            }
        }
    }

    /// Placeholder for adding an initial agent for demonstration.
    pub unsafe fn init_and_add_dummy_agent(&mut self, wasm_instance: WasmInstance) {
        let agent_ctx = AgentContext::new(wasm_instance, 1, self.quantum_ns);
        let agent_id = agent_ctx.agent_id;
        // This is a terrible way to manage agents for a real scheduler,
        // but for `no_std` and demonstration, it shows the concept.
        // A proper `no_std` heap-allocated `Vec` or custom list would be used.
        static mut AGENT_POOL_DUMMY: [Option<AgentContext>; 1] = [None];
        AGENT_POOL_DUMMY[0] = Some(agent_ctx);
        self.current_agent.store(AGENT_POOL_DUMMY[0].as_mut().unwrap() as *mut AgentContext, Ordering::Release);
        crate::println!("Dummy agent {} initialized and set as current.", agent_id);
    }
}

/// Global entry point for the timer interrupt handler.
/// This function is called from the assembly stub.
#[no_mangle]
pub extern "C" fn aether_timer_interrupt_entry(cpu_context: *mut CpuContext) {
    // Disable interrupts briefly to protect scheduler state
    // (or use spinlocks if SMP). For single-core, simple critical section.
    unsafe {
        // Acknowledge the interrupt controller
        // `APIC_CONTROLLER.eoi();`

        SCHEDULER.schedule_next_agent(&mut *cpu_context);
    }
}
```

### 3.3 Deadlock Resolution Strategies in a Multi-Agent Kernel

Deadlocks are a critical concern in multi-agent systems, especially when agents compete for shared resources (e.g., GPU memory, tool access, communication channels). AETHER-OS employs a combination of prevention and avoidance strategies:

*   **Resource Ordering:** Impose a strict global ordering on all shared resources. Agents must acquire resources in increasing order of their ID and release them in decreasing order. This prevents circular wait conditions.
*   **Timeouts and Preemption:** For some non-critical resources, agents can be given a timeout. If a resource isn't acquired within the timeout, the request fails. The kernel can also preempt resources from a blocking agent (e.g., if a high-priority agent needs it), though this requires careful design to avoid data corruption.
*   **Monitor and Allocate (Banker's Algorithm):** For critical, limited resources, AETHER-OS can employ an avoidance algorithm like the Banker's Algorithm. Agents declare their maximum resource needs upfront, and the kernel only grants requests if the system remains in a "safe state" (i.e., there's a sequence of allocations that allows all agents to complete). This can introduce overhead but guarantees no deadlocks.
*   **No Preemption of Critical Resources:** For very specific, non-sharable resources (e.g., an exclusive lock on a specific sensor), preemption is disallowed, relying on careful agent design and resource ordering.

The AETHER-OS kernel itself will be responsible for mediating resource requests and applying these strategies. Agents will make resource requests via host functions, which the kernel will intercept and process.

### 3.4 Conflict-Free Replicated Data Types (CRDTs) for Agent State

In a distributed agent swarm, agents often need to maintain shared state (e.g., shared beliefs, environmental models, task queues). Traditional consensus algorithms (like Paxos or Raft) are often too heavy-weight for real-time, low-latency agent interaction. Conflict-Free Replicated Data Types (CRDTs) offer an elegant solution by providing data structures that can be concurrently updated by multiple agents, and whose replicas can be merged without conflicts, always converging to the same state.

AETHER-OS will provide a set of CRDT primitives as host functions for agents. Examples include:
*   **G-Counter (Grow-Only Counter):** For distributed counters that only increment.
*   **PNCounter (Positive-Negative Counter):** For counters that can increment and decrement.
*   **G-Set (Grow-Only Set):** For sets where elements can only be added.
*   **OR-Set (Observed-Remove Set):** For sets where elements can be added and removed, handling concurrent removal correctly.
*   **LWW-Register (Last-Write-Wins Register):** For single-value registers, where conflicts are resolved by timestamp.

The kernel would manage the underlying replication and merging logic, exposing a simple API to WASM agents.

```rust
// src/crdt/mod.rs (Conceptual implementation for a G-Counter)
#![no_std]

use core::sync::atomic::{AtomicUsize, Ordering};

/// A simple G-Counter (Grow-Only Counter) CRDT.
/// Each replica maintains an array of counts, one for each contributing agent.
/// Only increments are allowed. Merging involves taking the maximum for each agent's count.
pub struct GCounter {
    // For a `no_std` environment, a fixed-size array or a custom
    // `no_std` `HashMap`-like structure mapping agent_id to count.
    // Let's assume a maximum of `MAX_AGENTS` for a fixed-size array.
    counts: [AtomicUsize; GCounter::MAX_AGENTS],
}

impl GCounter {
    pub const MAX_AGENTS: usize = 32; // Maximum number of agents contributing to this counter

    /// Creates a new G-Counter, initialized to all zeros.
    pub const fn new() -> Self {
        // AtomicUsize::new(0) is not `const fn` until Rust 1.70+
        // For older `no_std` (or pre-1.70), this would need manual initialization
        // in a non-const `init` function.
        // For now, assume it's possible or use `unsafe` for initialization.
        let counts = [
            AtomicUsize::new(0), AtomicUsize::new(0), AtomicUsize::new(0), AtomicUsize::new(0),
            AtomicUsize::new(0), AtomicUsize::new(0), AtomicUsize::new(0), AtomicUsize::new(0),
            AtomicUsize::new(0), AtomicUsize::new(0), AtomicUsize::new(0), AtomicUsize::new(0),
            AtomicUsize::new(0), AtomicUsize::new(0), AtomicUsize::new(0), AtomicUsize::new(0),
            AtomicUsize::new(0), AtomicUsize::new(0), AtomicUsize::new(0), AtomicUsize::new(0),
            AtomicUsize::new(0), AtomicUsize::new(0), AtomicUsize::new(0), AtomicUsize::new(0),
            AtomicUsize::new(0), AtomicUsize::new(0), AtomicUsize::new(0), AtomicUsize::new(0),
            AtomicUsize::new(0), AtomicUsize::new(0), AtomicUsize::new(0), AtomicUsize::new(0),
        ];
        GCounter { counts }
    }

    /// Increments the counter for a specific agent.
    /// `agent_idx`: The index (or ID) of the agent performing the increment.
    pub fn increment(&self, agent_idx: usize) {
        if agent_idx < Self::MAX_AGENTS {
            self.counts[agent_idx].fetch_add(1, Ordering::Relaxed);
        }
    }

    /// Merges this G-Counter with another G-Counter.
    /// For each agent, the count is the maximum of the two counters.
    pub fn merge(&self, other: &GCounter) {
        for i in 0..Self::MAX_AGENTS {
            let self_count = self.counts[i].load(Ordering::Relaxed);
            let other_count = other.counts[i].load(Ordering::Relaxed);
            let max_count = self_count.max(other_count);
            self.counts[i].store(max_count, Ordering::Relaxed);
        }
    }

    /// Returns the total value of the counter.
    pub fn value(&self) -> usize {
        let mut total = 0;
        for i in 0..Self::MAX_AGENTS {
            total += self.counts[i].load(Ordering::Relaxed);
        }
        total
    }
}
```

### 3.5 Lock-Free Vector Clock Implementation for Causal Ordering

Vector clocks are essential for establishing causal ordering of events in a distributed system without relying on perfectly synchronized physical clocks. Each agent maintains its own vector clock, which is an array (or map) of counters, one for every agent in the swarm.

#### 3.5.1 The Challenge of Distributed Time

In an asynchronous agent swarm, an event `A` "happens before" an event `B` if `A` could causally influence `B`. This is critical for understanding dependencies and ensuring consistency. Traditional timestamps are insufficient because clocks can drift. Vector clocks provide a robust mechanism for this.

Rules for Vector Clocks:
1.  **Local Event:** When an agent `i` performs an event, it increments its own counter `V[i]`.
2.  **Send Message:** When agent `i` sends a message, it includes a copy of its current vector clock `V`.
3.  **Receive Message:** When agent `j` receives a message with vector clock `V_msg` from agent `i`:
    *   It updates its own clock `V` by taking the element-wise maximum of `V` and `V_msg`.
    *   It then increments its own counter `V[j]`.

#### 3.5.2 Atomic Operations for Vector Clock Updates

Implementing a vector clock in a lock-free manner in `no_std` Rust requires careful use of atomic operations, specifically `fetch_add` for local increments and `compare_exchange` (or `fetch_max` if available for the specific type) for merging.

```rust
// src/crdt/vector_clock.rs
#![no_std]

use core::sync::atomic::{AtomicU64, Ordering};

/// A lock-free vector clock implementation.
/// Each entry in the vector corresponds to an agent's logical clock.
pub struct VectorClock {
    // Fixed size for simplicity in `no_std`. In a dynamic system,
    // this would be a dynamically sized `no_std` map or similar.
    clocks: [AtomicU64; VectorClock::MAX_AGENTS],
    own_agent_idx: usize,
}

impl VectorClock {
    pub const MAX_AGENTS: usize = 32;

    /// Creates a new VectorClock for a specific agent.
    pub const fn new(own_agent_idx: usize) -> Self {
        // Initialize all clocks to 0.
        // Similar to GCounter, requires `const fn` for AtomicU64::new.
        let clocks = [
            AtomicU64::new(0), AtomicU64::new(0), AtomicU64::new(0), AtomicU64::new(0),
            AtomicU64::new(0), AtomicU64::new(0), AtomicU64::new(0), AtomicU64::new(0),
            AtomicU64::new(0), AtomicU64::new(0), AtomicU64::new(0), AtomicU64::new(0),
            AtomicU64::new(0), AtomicU64::new(0), AtomicU64::new(0), AtomicU64::new(0),
            AtomicU64::new(0), AtomicU64::new(0), AtomicU64::new(0), AtomicU64::new(0),
            AtomicU64::new(0), AtomicU64::new(0), AtomicU64::new(0), AtomicU64::new(0),
            AtomicU64::new(0), AtomicU64::new(0), AtomicU64::new(0), AtomicU64::new(0),
            AtomicU64::new(0), AtomicU64::new(0), AtomicU64::new(0), AtomicU64::new(0),
        ];
        VectorClock { clocks, own_agent_idx }
    }

    /// Increments this agent's logical clock counter.
    pub fn increment(&self) {
        if self.own_agent_idx < Self::MAX_AGENTS {
            self.clocks[self.own_agent_idx].fetch_add(1, Ordering::Relaxed);
        }
    }

    /// Merges this vector clock with another vector clock (e.g., received from a message).
    pub fn merge(&self, other: &VectorClock) {
        for i in 0..Self::MAX_AGENTS {
            let mut current_val = self.clocks[i].load(Ordering::Relaxed);
            let other_val = other.clocks[i].load(Ordering::Relaxed);

            // Atomically update `self.clocks[i]` to `max(current_val, other_val)`
            // Loop with `compare_exchange` to ensure atomicity and handle contention.
            while current_val < other_val {
                match self.clocks[i].compare_exchange_weak(
                    current_val,
                    other_val,
                    Ordering::Relaxed,
                    Ordering::Relaxed,
                ) {
                    Ok(_) => break, // Successfully updated
                    Err(v) => current_val = v, // Value changed, retry with new value
                }
            }
        }
        // After merging, increment own clock (rule 3 part 2)
        self.increment();
    }

    /// Compares two vector clocks to determine their causal relationship.
    /// Returns:
    ///   - `Ordering::Less` if `self` causally precedes `other` (`self < other`).
    ///   - `Ordering::Greater` if `other` causally precedes `self` (`other < self`).
    ///   - `Ordering::Equal` if `self` and `other` are identical.
    ///   - `Ordering::Equal` (or custom `Ordering::Incomparable`) if they are concurrent.
    pub fn compare(&self, other: &VectorClock) -> core::cmp::Ordering {
        let mut self_is_less = false;
        let mut other_is_less = false;

        for i in 0..Self::MAX_AGENTS {
            let self_val = self.clocks[i].load(Ordering::Relaxed);
            let other_val = other.clocks[i].load(Ordering::Relaxed);

            if self_val < other_val {
                self_is_less = true;
            }
            if other_val < self_val {
                other_is_less = true;
            }
        }

        if self_is_less && !other_is_less {
            core::cmp::Ordering::Less // self happened before other
        } else if other_is_less && !self_is_less {
            core::cmp::Ordering::Greater // other happened before self
        } else if !self_is_less && !other_is_less {
            // All components are equal (or self_val >= other_val for all i and other_val >= self_val for all i)
            let mut equal = true;
            for i in 0..Self::MAX_AGENTS {
                if self.clocks[i].load(Ordering::Relaxed) != other.clocks[i].load(Ordering::Relaxed) {
                    equal = false;
                    break;
                }
            }
            if equal { core::cmp::Ordering::Equal } else { core::cmp::Ordering::Equal } // Incomparable (concurrent)
            // A more precise enum for comparison might include `Concurrent`.
            // For `Ordering` enum, concurrent is typically treated as `Equal` or handled specially.
        } else {
            core::cmp::Ordering::Equal // Concurrent (e.g., self_val < other_val for some, other_val < self_val for others)
        }
    }

    /// Returns a copy of the current vector clock state.
    pub fn get_current_state(&self) -> [u64; VectorClock::MAX_AGENTS] {
        let mut state = [0; Self::MAX_AGENTS];
        for i in 0..Self::MAX_AGENTS {
            state[i] = self.clocks[i].load(Ordering::Relaxed);
        }
        state
    }
}
```

### 3.6 Rust Implementation: Agent Scheduler and Vector Clock

The scheduler module and CRDTs are fundamental to AETHER-OS. The `Scheduler` manages `AgentContext`s, performing the actual context switches. The `VectorClock` and `GCounter` provide tools for agents to maintain consistent distributed state.

The `aether_timer_interrupt_entry` function is the kernel's critical path for preemption, demonstrating how the `CpuContext` is saved and restored, and the `MmuController::switch_context` is invoked to enforce memory isolation. This entire process must execute in microseconds to meet the zero-latency requirement.

This chapter has detailed the mechanisms for orchestrating autonomous AI agents, ensuring fair execution, preventing deadlocks, and maintaining causal consistency across the swarm. The next chapter will focus on how agents access long-term memory and dynamically call tools, tying together the runtime, IPC, and scheduling components.

---

## Chapter 4: Dynamic Tool-Calling Memory Bus & Context Switching

### 4.1 Bridging Agents to the External World: The Tool-Calling Bus

Autonomous AI agents are not isolated entities; they must interact with their environment, access vast amounts of information, and leverage specialized tools (e.g., external APIs, databases, advanced perception modules). For AETHER-OS, this interaction must be:
*   **Hard Real-Time:** Tool calls and memory accesses must have predictable, bounded latencies.
*   **Dynamic:** Agents should be able to discover and invoke tools based on their current goals and context.
*   **Secure:** Access to tools and long-term memory must adhere to the sandbox isolation principles.

The **AETHER-OS Memory Bus** is a conceptual and architectural construct that facilitates these interactions. It provides a unified, high-throughput channel for agents to:
1.  Access their **Long-Term Memory (LTM)**, typically implemented as a Vector Store.
2.  Invoke **Tool Functions** exposed by the AETHER-OS kernel or other specialized services.
3.  Perform fast **Context Switching** between agent states.

### 4.2 AETHER-OS Memory Bus Architecture

The Memory Bus isn't a physical bus in the traditional sense, but a set of kernel services and memory-mapping strategies that provide a consistent interface for agents.

#### 4.2.1 Virtual Address Space Management for Agents

Each WASM agent operates within its own virtual address space, managed by the MMU (as discussed in Chapter 1). The AETHER-OS kernel carefully maps different types of memory into these spaces:
*   **Agent Linear Memory:** Private read/write, non-executable (for WASM data).
*   **Agent Code Memory:** Private read-only, executable (for AOT-compiled WASM code).
*   **Shared Kernel Memory:** Read-only access to kernel data structures (e.g., system configuration, read-only CRDT replicas).
*   **Tool-Calling Interface:** A dedicated memory region mapped into the agent's space, containing trampolines or pointers to host functions.
*   **Long-Term Memory (Vector Store):** Shared read-only access to the vector store index and embeddings, potentially with read/write access to agent-specific scratchpads.

#### 4.2.2 Shared Memory Regions for Tool Access and Vector Stores

For optimal performance, critical shared resources like the Vector Store and the Tool-Calling Interface are mapped directly into the agents' virtual address spaces.

**Tool-Calling Interface:**
*   A fixed virtual address range is reserved for the tool-calling interface.
*   Within this range, a table of function pointers (or a jump table) is exposed. Each entry corresponds to a host function (e.g., `aether_os_call_gpu_ipc`, `aether_os_query_vector_store`).
*   WASM agents, through their AOT-compiled code, can make direct calls to these "pseudo-addresses," which are then intercepted by the kernel (via a system call, or a direct jump if the target is in kernel space and permissions allow).

**Vector Store Memory:**
*   The Vector Store's index and embedding data are pre-loaded into a large, contiguous physical memory region.
*   This region is then mapped as read-only into the virtual address space of all agents that require LTM access.
*   This allows agents to perform similarity searches directly on the data without copying, leveraging hardware-accelerated search routines (see 4.4).

### 4.3 Hard-Real-Time Context Switching for Agent Execution

The `AgentContext` structure introduced in Chapter 3 is central to fast context switching. AETHER-OS aims for context switches in the order of hundreds of nanoseconds to a few microseconds, making it a "hard real-time" operation.

#### 4.3.1 CPU Register Preservation and Restoration

The core of context switching involves saving the current CPU's register state and loading the state of the next agent. This is typically done in highly optimized assembly code within the interrupt handler.

```rust
// src/kernel/context_switch_asm.s (Conceptual x86-64 assembly)
// This file would be compiled separately and linked with the Rust kernel.

.global _aether_save_context
.global _aether_restore_context
.global _aether_first_schedule_entry

// _aether_save_context: Saves current CPU state into `AgentContext`
// Arguments:
//   rdi: *mut AgentContext (pointer to the ACB to save into)
_aether_save_context:
    // Save general-purpose registers
    mov [rdi + 0x00], r15 // Assuming AgentContext layout matches
    mov [rdi + 0x08], r14
    mov [rdi + 0x10], r13
    mov [rdi + 0x18], r12
    mov [rdi + 0x20], r11
    mov [rdi + 0x28], r10
    mov [rdi + 0x30], r9
    mov [rdi + 0x38], r8
    mov [rdi + 0x40], rbp
    mov [rdi + 0x48], rsi
    mov [rdi + 0x50], rdi // RDI holds the AgentContext pointer, save it
    mov [rdi + 0x58], rdx
    mov [rdi + 0x60], rcx
    mov [rdi + 0x68], rbx
    mov [rdi + 0x70], rax

    // Save current stack pointer (RSP)
    mov [rdi + 0x78], rsp

    // Save RFLAGS and RIP (these are usually on the interrupt stack frame
    // when coming from an interrupt. For a voluntary switch, we need to push them).
    // For a preemptive switch, the interrupt handler's entry stub would have pushed these.
    // If this is called from Rust, we need to manually get RFLAGS/RIP.
    // Let's assume this is part of the interrupt context saving.
    // For now, these are conceptually handled by the interrupt entry.
    // mov [rdi + 0x80], rflags ; // Get from interrupt stack frame if applicable
    // mov [rdi + 0x88], rip    ; // Get from interrupt stack frame if applicable

    ret // Return to the Rust scheduler logic

// _aether_restore_context: Restores CPU state from `AgentContext` and jumps to it
// Arguments:
//   rdi: *const AgentContext (pointer to the ACB to restore from)
_aether_restore_context:
    // Restore general-purpose registers
    mov r15, [rdi + 0x00]
    mov r14, [rdi + 0x08]
    mov r13, [rdi + 0x10]
    mov r12, [rdi + 0x18]
    mov r11, [rdi + 0x20]
    mov r10, [rdi + 0x28]
    mov r9,  [rdi + 0x30]
    mov r8,  [rdi + 0x38]
    mov rbp, [rdi + 0x40]
    mov rsi, [rdi + 0x48]
    mov rdx, [rdi + 0x58]
    mov rcx, [rdi + 0x60]
    mov rbx, [rdi + 0x68]
    mov rax, [rdi + 0x70]

    // Restore RFLAGS
    // push qword [rdi + 0x80] ; // Push RFLAGS from ACB
    // popf                     ; // Restore RFLAGS

    // Restore RSP and RIP, then jump to RIP.
    // This is often done by setting up an interrupt stack frame manually,
    // then executing `iretq`.
    mov rsp, [rdi + 0x78] // Set the new stack pointer
    // For `iretq` to work, the stack must contain SS, RSP, RFLAGS, CS, RIP in order.
    // The interrupt entry stub would have prepared this.
    // If this is a direct jump for a "first schedule", we'd do:
    mov rdi, [rdi + 0x50] // Restore original RDI (if it was part of saved context)
    jmp qword [rdi + 0x88] // Jump to the saved RIP (Instruction Pointer)

// _aether_first_schedule_entry: Special entry for the very first time an agent is scheduled.
// This function sets up the stack frame for `iretq` and then executes it.
// Arguments:
//   rdi: *const AgentContext (pointer to the ACB to restore from)
_aether_first_schedule_entry:
    // Restore general-purpose registers (same as _aether_restore_context, excluding RSP, RIP, RFLAGS)
    mov r15, [rdi + 0x00]
    mov r14, [rdi + 0x08]
    mov r13, [rdi + 0x10]
    mov r12, [rdi + 0x18]
    mov r11, [rdi + 0x20]
    mov r10, [rdi + 0x28]
    mov r9,  [rdi + 0x30]
    mov r8,  [rdi + 0x38]
    mov rbp, [rdi + 0x40]
    mov rsi, [rdi + 0x48]
    mov rdx, [rdi + 0x58]
    mov rcx, [rdi + 0x60]
    mov rbx, [rdi + 0x68]
    mov rax, [rdi + 0x70]

    // Manually push an IRETQ stack frame:
    // SS (segment selector, typically 0 for bare metal/flat model)
    // RSP (the agent's stack pointer)
    // RFLAGS (agent's flags)
    // CS (code segment, typically 0)
    // RIP (agent's instruction pointer)
    push qword 0x0 // Dummy SS (or actual user data segment if defined)
    push qword [rdi + 0x78] // Agent's RSP
    push qword [rdi + 0x80] // Agent's RFLAGS
    push qword 0x0 // Dummy CS (or actual user code segment if defined)
    push qword [rdi + 0x88] // Agent's RIP

    iretq // Return from interrupt, effectively starting the agent's execution
```

#### 4.3.2 WASM Runtime State Management

Beyond CPU registers, the WASM runtime itself has internal state (its own evaluation stack, locals, global variables, etc.). When AETHER-OS performs a context switch, the `WasmInstance` (embedded in `AgentContext`) must also have its internal state saved and restored.
*   **WASM Stack:** The WASM linear memory contains the WASM stack. The `stack_ptr` in `WasmInstance` tracks its top.
*   **WASM Locals/Globals:** These are typically part of the `WasmInstance` data structure and are preserved automatically when the `AgentContext` is saved.
*   **WASM Program Counter:** The `program_counter` in `WasmInstance` tracks the next WASM instruction to execute.

The `AgentContext::save_cpu_context` and `AgentContext::restore_cpu_context` functions (or their assembly counterparts) handle the CPU registers. The `WasmInstance` itself would manage its internal WASM-specific state.

### 4.4 Hardware-Accelerated Similarity Search for Long-Term Memory

The Long-Term Memory (LTM) for AI agents is often a vector store, where concepts, experiences, and facts are represented as high-dimensional vectors. Retrieving relevant information involves performing similarity searches (e.g., k-Nearest Neighbors or approximate k-NN) against a vast database of vectors. This is a computationally intensive task, ideally suited for hardware acceleration.

#### 4.4.1 Integrating Vector Store Search with the Memory Bus

AETHER-OS will integrate a hardware-accelerated vector store directly into the Memory Bus architecture.
*   **Vector Store Data Layout:** The vector store's index (e.g., FAISS, HNSW) and the raw embedding data are loaded into GPU Unified Memory or dedicated GPU device memory.
*   **Host Function Interface:** A specific host function (e.g., `aether_os_query_vector_store`) is exposed to WASM agents. This function takes a query vector (passed as a pointer into the agent's linear memory) and parameters (e.g., number of neighbors `k`).
*   **Kernel Mediation:** When an agent calls this host function, the AETHER-OS kernel:
    1.  Validates the agent's access rights and query parameters.
    2.  Translates the agent's virtual memory pointer for the query vector into a physical/GPU memory address.
    3.  Invokes a specialized CUDA kernel (or other accelerator API) to perform the similarity search on the GPU.
    4.  The results (e.g., `k` nearest neighbors and their distances) are written back into a pre-allocated buffer in the agent's linear memory.

#### 4.4.2 Leveraging GPU Acceleration for k-NN Search

CUDA-accelerated libraries like FAISS (Facebook AI Similarity Search) are highly optimized for k-NN search on GPUs. AETHER-OS will wrap these capabilities.

```cpp
// src/gpu/vector_store_kernel.cu
#include <cuda_runtime.h>
#include <cuda_fp16.h>
#include <faiss/gpu/GpuIndexFlat.h> // Example: using FAISS GPU
#include <faiss/gpu/GpuIndexIVFFlat.h> // For IVF-based approximate search
#include <faiss/index_io.h> // For loading FAISS index
#include <cstdio>

// Assume a pre-loaded FAISS index.
// In a real system, this would be loaded from disk into GPU memory at boot.
faiss::gpu::GpuIndex* global_faiss_gpu_index = nullptr;
int embedding_dimension = 0;

#define CHECK_CUDA_FAISS(call) \
    do { \
        cudaError_t err = call; \
        if (err != cudaSuccess) { \
            fprintf(stderr, "CUDA error in FAISS wrapper %s:%d - %s\n", __FILE__, __LINE__, cudaGetErrorString(err)); \
            return err; \
        } \
    } while (0)

extern "C" {
    /// Initializes the FAISS GPU index.
    /// `index_path`: Path to a pre-trained FAISS index file (e.g., on a virtual filesystem).
    /// `dim`: Dimensionality of the embeddings.
    /// Returns cudaSuccess on success.
    cudaError_t init_faiss_gpu_index(const char* index_path, int dim) {
        if (global_faiss_gpu_index) {
            fprintf(stderr, "FAISS GPU index already initialized.\n");
            return cudaErrorInvalidConfiguration;
        }

        faiss::Index* cpu_index = faiss::read_index(index_path);
        if (!cpu_index) {
            fprintf(stderr, "Failed to read FAISS CPU index from %s\n", index_path);
            return cudaErrorInvalidValue;
        }

        faiss::gpu::GpuIndexFlatConfig config;
        config.device = 0; // Use GPU device 0

        // For large-scale indexes, GpuIndexIVFFlat is better. For small demos, GpuIndexFlat.
        // We need to ensure the CPU index is compatible with GPU.
        global_faiss_gpu_index = faiss::gpu::index_factory_by_id(config.device, cpu_index->d, "Flat");
        if (!global_faiss_gpu_index) {
            fprintf(stderr, "Failed to create FAISS GPU index.\n");
            delete cpu_index;
            return cudaErrorInvalidConfiguration;
        }

        global_faiss_gpu_index->copyFrom(cpu_index);
        embedding_dimension = dim;
        delete cpu_index; // CPU index can be freed after copying to GPU

        fprintf(stdout, "FAISS GPU index initialized successfully. Dimension: %d\n", dim);
        return cudaSuccess;
    }

    /// Performs a k-Nearest Neighbors search on the FAISS GPU index.
    /// `query_vector`: Pointer to the query embedding (float or half-float).
    /// `k`: Number of nearest neighbors to retrieve.
    /// `distances_out`: Output buffer for distances (float array).
    /// `labels_out`: Output buffer for labels (long long array).
    /// `num_queries`: Number of query vectors in the batch (e.g., 1 for single query).
    cudaError_t faiss_gpu_knn_search(
        const __half* query_vector, // Assuming half-precision embeddings
        int k,
        float* distances_out,
        long long* labels_out,
        int num_queries
    ) {
        if (!global_faiss_gpu_index) {
            fprintf(stderr, "FAISS GPU index not initialized.\n");
            return cudaErrorNotInitialized;
        }
        if (embedding_dimension == 0) {
            fprintf(stderr, "Embedding dimension not set.\n");
            return cudaErrorInvalidConfiguration;
        }

        // FAISS expects float arrays, so we might need to convert __half to float on GPU.
        // For simplicity, let's assume `query_vector` is already float for FAISS input,
        // or a conversion kernel runs first.
        // A direct FAISS call expects `float*`. Let's assume input is `float*`.
        // If the agent uses `__half`, a small kernel to convert could be run here.
        float* query_vector_float;
        CHECK_CUDA_FAISS(cudaMalloc(&query_vector_float, num_queries * embedding_dimension * sizeof(float)));
        // Example: Convert from __half to float
        // __global__ void convert_half_to_float(__half* in, float* out, int count) { ... }
        // For now, assume query_vector is already float for direct FAISS use.

        // Perform the search
        try {
            global_faiss_gpu_index->search(num_queries, (const float*)query_vector, k, distances_out, labels_out);
        } catch (const faiss::FaissException& e) {
            fprintf(stderr, "FAISS search error: %s\n", e.what());
            return cudaErrorLaunchFailure;
        }

        CHECK_CUDA_FAISS(cudaDeviceSynchronize()); // Ensure search completes

        // CHECK_CUDA_FAISS(cudaFree(query_vector_float)); // Free converted query if done here
        return cudaSuccess;
    }

    /// Destroys the FAISS GPU index.
    cudaError_t destroy_faiss_gpu_index() {
        if (global_faiss_gpu_index) {
            delete global_faiss_gpu_index;
            global_faiss_gpu_index = nullptr;
            fprintf(stdout, "FAISS GPU index destroyed.\n");
        }
        return cudaSuccess;
    }
}
```

### 4.5 Rust Implementation: Memory Bus and Context Switching Primitives

The AETHER-OS kernel in Rust will provide the FFI interface for agents to call these GPU-accelerated services and manage the context switching.

```rust
// src/kernel/mod.rs (Illustrative additions)
#![no_std]

// ... other modules ...
use crate::scheduler::acb::{AgentContext, CpuContext};
use crate::gpu::vector_store_ffi::{cudaError_t, init_faiss_gpu_index, faiss_gpu_knn_search, destroy_faiss_gpu_index};
use core::ptr;
use core::ffi::{c_char, c_int, c_longlong};

// Define FFI for context switching assembly routines
extern "C" {
    fn _aether_save_context(ctx: *mut AgentContext);
    fn _aether_restore_context(ctx: *const AgentContext);
    fn _aether_first_schedule_entry(ctx: *const AgentContext) -> !; // Diverging function
}

/// AETHER-OS Memory Bus module.
/// Manages shared memory regions and provides host functions for agents.
pub struct MemoryBus;

impl MemoryBus {
    /// Initializes the memory bus, including the vector store.
    pub unsafe fn init() -> Result<(), &'static str> {
        // Initialize FAISS GPU index.
        // In a real system, the index path would be a kernel-managed resource.
        // For demonstration, a dummy path.
        let dummy_index_path = b"/mnt/aether_fs/faiss_index.bin\0"; // Null-terminated C string
        let cuda_err = init_faiss_gpu_index(dummy_index_path.as_ptr() as *const c_char, 768); // Example dim
        if cuda_err.is_success() {
            crate::println!("Vector store initialized on GPU.");
            Ok(())
        } else {
            Err("Failed to initialize FAISS GPU index.")
        }
    }

    /// Cleans up memory bus resources.
    pub unsafe fn shutdown() -> Result<(), &'static str> {
        let cuda_err = destroy_faiss_gpu_index();
        if cuda_err.is_success() {
            crate::println!("Vector store shut down.");
            Ok(())
        } else {
            Err("Failed to destroy FAISS GPU index.")
        }
    }

    /// Host function: Allows a WASM agent to perform a k-NN search.
    /// This would be exposed via the WASI-Lite interface to WASM.
    /// `agent_id`: ID of the calling agent (for logging/permissions).
    /// `query_ptr`: Virtual address within the agent's linear memory pointing to the query vector.
    /// `k`: Number of nearest neighbors.
    /// `distances_out_ptr`: Virtual address for output distances.
    /// `labels_out_ptr`: Virtual address for output labels.
    /// `num_queries`: Number of queries (batch size, typically 1 for single agent).
    pub unsafe fn agent_knn_search(
        agent_id: u32,
        query_ptr: usize,
        k: c_int,
        distances_out_ptr: usize,
        labels_out_ptr: usize,
        num_queries: c_int,
    ) -> cudaError_t {
        // 1. Validate agent_id and permissions.
        // 2. Translate agent's virtual addresses to kernel's physical/virtual addresses.
        //    This requires the MMU to be consulted.
        let physical_query_ptr = MmuController::translate_virt_to_phys(agent_id, query_ptr);
        let physical_distances_out_ptr = MmuController::translate_virt_to_phys(agent_id, distances_out_ptr);
        let physical_labels_out_ptr = MmuController::translate_virt_to_phys(agent_id, labels_out_ptr);

        if physical_query_ptr.is_none() || physical_distances_out_ptr.is_none() || physical_labels_out_ptr.is_none() {
            crate::eprintln!("Agent {} tried to access invalid memory for KNN search.", agent_id);
            return cudaError_t(2); // cudaErrorInvalidValue
        }

        // Call the CUDA kernel. Assuming `query_ptr` points to `__half` data in agent's memory.
        faiss_gpu_knn_search(
            physical_query_ptr.unwrap() as *const u16, // Cast to u16 for __half
            k,
            physical_distances_out_ptr.unwrap() as *mut f32,
            physical_labels_out_ptr.unwrap() as *mut c_longlong,
            num_queries,
        )
    }

    // Other host functions for tool calling would follow a similar pattern.
    // e.g., `agent_call_external_api(url_ptr, payload_ptr)`
}

// src/scheduler/mod.rs (Revisiting the scheduler with actual context switch calls)
// ... (previous code) ...

impl Scheduler {
    // ... (add_agent, get_next_ready_agent, init_and_add_dummy_agent) ...

    /// Executes a full context switch: saves current, loads next.
    /// This is called by the `aether_timer_interrupt_entry` function.
    /// `current_cpu_context_ptr`: Pointer to the `CpuContext` saved by the interrupt handler.
    pub unsafe fn perform_context_switch(&mut self, current_cpu_context_ptr: *mut CpuContext) {
        let current_agent_ptr = self.current_agent.load(Ordering::Acquire);

        if !current_agent_ptr.is_null() {
            let current_agent = &mut *current_agent_ptr;
            // Save the CPU context from the interrupt stack into the current agent's ACB.
            current_agent.save_cpu_context(&*current_cpu_context_ptr);
            current_agent.status = AgentStatus::Ready;
            current_agent.time_slice_ns = self.quantum_ns; // Reset quantum
            // Enqueue current_agent back to the ready queue (conceptual for now)
        }

        // Select the next agent to run.
        let next_agent_option = self.get_next_ready_agent();

        if let Some(next_agent_nn) = next_agent_option {
            let next_agent = next_agent_nn.as_mut();
            next_agent.status = AgentStatus::Running;
            next_agent.last_scheduled_time = time::monotonic_time_ns();
            self.current_agent.store(next_agent_nn.as_ptr(), Ordering::Release);

            // Restore the CPU context from the next agent's ACB into the interrupt stack frame.
            next_agent.restore_cpu_context(&mut *current_cpu_context_ptr);
            // The interrupt return (iretq) will then jump to next_agent's RIP.
        } else {
            // No agents ready to run.
            // In a real system, this would transition to an idle loop or halt.
            // For now, if no agents, we'll just return from interrupt and potentially re-enter
            // the previous context (if it was an idle task) or halt.
            self.current_agent.store(ptr::null_mut(), Ordering::Release);
            crate::println!("No agents ready to run. Entering idle state.");
            // A real idle state would involve putting the CPU to sleep.
        }
    }

    /// Special function for the first time an agent is ever scheduled.
    /// This function does not save a previous context, but rather sets up the stack
    /// for the `_aether_first_schedule_entry` assembly routine to jump into the agent.
    pub unsafe fn start_first_agent(&mut self, agent: AgentContext) -> ! {
        let agent_ptr = NonNull::new_unchecked(&mut agent as *mut AgentContext);
        self.current_agent.store(agent_ptr.as_ptr(), Ordering::Release);
        agent_ptr.as_mut().status = AgentStatus::Running;
        agent_ptr.as_mut().last_scheduled_time = time::monotonic_time_ns();

        // Call the assembly routine to perform the very first context switch.
        // This function will not return.
        _aether_first_schedule_entry(agent_ptr.as_ptr())
    }
}

// src/kernel/interrupts.rs (Modified timer interrupt handler)
// ... (CpuContext definition) ...

// The global scheduler instance (already defined in scheduler/mod.rs)
// static mut SCHEDULER: Scheduler = Scheduler { ... };

/// Global entry point for the timer interrupt handler.
/// This function is called from the assembly stub, with the CPU context on stack.
#[no_mangle]
pub extern "C" fn aether_timer_interrupt_entry(cpu_context_ptr: *mut CpuContext) {
    // Acknowledge the interrupt controller (e.g., APIC EOI)
    // apic::eoi();

    // Perform the context switch
    unsafe {
        // Obtain a mutable reference to the global scheduler.
        // This access needs to be protected, e.g., by disabling interrupts or using a spinlock
        // for multi-core systems. For a single-core preemptive kernel, disabling interrupts
        // around critical scheduler sections is common.
        let scheduler_ref = &mut *ptr::addr_of_mut!(crate::scheduler::SCHEDULER);
        scheduler_ref.perform_context_switch(cpu_context_ptr);
    }
}
```

This final chapter has detailed the architecture and implementation of the AETHER-OS Memory Bus, enabling dynamic tool calling and high-performance access to long-term memory. It has also cemented the low-level context switching mechanisms that ensure hard real-time performance for agent execution. By combining bare-metal WASM isolation, zero-copy GPU IPC, deterministic scheduling with CRDTs, and a hardware-accelerated memory bus, Project AETHER-OS provides a robust, high-value foundation for the next generation of autonomous AI agent swarms.