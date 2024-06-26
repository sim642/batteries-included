(*
 * BatGC - Extended GC operations
 * Copyright (C) 1996 Damien Doligez
 *               2008 David Teller, LIFO, Universite d'Orleans
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version,
 * with the special exception on linking described in file LICENSE.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *)


(** Memory management control and statistics; finalised values.

    This module extends Stdlib's
    {{:http://caml.inria.fr/pub/docs/manual-ocaml/libref/Gc.html}Gc}
    module, go there for documentation on the rest of the functions
    and types.

    @author Damien Doligez (Base module)
    @author David Teller
*)

type stat = Gc.stat =
  { minor_words : float;
    (** Number of words allocated in the minor heap since
        the program was started.  This number is accurate in
        byte-code programs, but only an approximation in programs
        compiled to native code. *)

    promoted_words : float;
    (** Number of words allocated in the minor heap that
        survived a minor collection and were moved to the major heap
        since the program was started. *)

    major_words : float;
    (** Number of words allocated in the major heap, including
        the promoted words, since the program was started. *)

    minor_collections : int;
    (** Number of minor collections since the program was started. *)

    major_collections : int;
    (** Number of major collection cycles completed since the program
        was started. *)

    heap_words : int;
    (** Total size of the major heap, in words. *)

    heap_chunks : int;
    (** Number of contiguous pieces of memory that make up the major heap. *)

    live_words : int;
    (** Number of words of live data in the major heap, including the header
        words. *)

    live_blocks : int;
    (** Number of live blocks in the major heap. *)

    free_words : int;
    (** Number of words in the free list. *)

    free_blocks : int;
    (** Number of blocks in the free list. *)

    largest_free : int;
    (** Size (in words) of the largest block in the free list. *)

    fragments : int;
    (** Number of wasted words due to fragmentation.  These are
        1-words free blocks placed between two live blocks.  They
        are not available for allocation. *)

    compactions : int;
    (** Number of heap compactions since the program was started. *)

    top_heap_words : int;
    (** Maximum size reached by the major heap, in words. *)

    stack_size: int;
    (** Current size of the stack, in words.

        @since 3.12.0 *)

##V>=4.12## forced_major_collections: int;
##V>=4.12## (** Number of forced full major collections completed since the program
##V>=4.12##     was started.
##V>=4.12##     @since 4.12.0 *)
  }
(** The memory management counters are returned in a [stat] record.

    The total amount of memory allocated by the program since it was started
    is (in words) [minor_words + major_words - promoted_words].  Multiply by
    the word size (4 on a 32-bit machine, 8 on a 64-bit machine) to get
    the number of bytes.
*)

type control = Gc.control =
  {
##V<5.0## mutable
      minor_heap_size : int;
    (** The size (in words) of the minor heap.  Changing
        this parameter will trigger a minor collection.  Default: 32k. *)

##V<5.0## mutable
      major_heap_increment : int;
    (** The minimum number of words to add to the
        major heap when increasing it.  Default: 124k. *)

##V<5.0## mutable
      space_overhead : int;
    (** The major GC speed is computed from this parameter.
        This is the memory that will be "wasted" because the GC does not
        immediately collect unreachable blocks.  It is expressed as a
        percentage of the memory used for live data.
        The GC will work more (use more CPU time and collect
        blocks more eagerly) if [space_overhead] is smaller.
        Default: 80. *)

##V<5.0## mutable
      verbose : int;
    (** This value controls the GC messages on standard error output.
        It is a sum of some of the following flags, to print messages
        on the corresponding events:
        - [0x001] Start of major GC cycle.
        - [0x002] Minor collection and major GC slice.
        - [0x004] Growing and shrinking of the heap.
        - [0x008] Resizing of stacks and memory manager tables.
        - [0x010] Heap compaction.
        - [0x020] Change of GC parameters.
        - [0x040] Computation of major GC slice size.
        - [0x080] Calling of finalisation functions.
        - [0x100] Bytecode executable search at start-up.
        - [0x200] Computation of compaction triggering condition.
        Default: 0. *)

##V<5.0## mutable
      max_overhead : int;
    (** Heap compaction is triggered when the estimated amount
        of "wasted" memory is more than [max_overhead] percent of the
        amount of live data.  If [max_overhead] is set to 0, heap
        compaction is triggered at the end of each major GC cycle
        (this setting is intended for testing purposes only).
        If [max_overhead >= 1000000], compaction is never triggered.
        Default: 500. *)

##V<5.0## mutable
      stack_limit : int;
    (** The maximum size of the stack (in words).  This is only
        relevant to the byte-code runtime, as the native code runtime
        uses the operating system's stack.  Default: 256k. *)

##V<5.0## mutable
      allocation_policy : int;
    (** The policy used for allocating in the heap.  Possible
        values are 0 and 1.  0 is the next-fit policy, which is
        quite fast but can result in fragmentation.  1 is the
        first-fit policy, which can be slower in some cases but
        can be better for programs with fragmentation problems.
        Default: 0.

        @since 3.11.0 *)

##V>=4.3##    window_size : int;
##V>=4.3##    (** The size of the window used by the major GC for smoothing
##V>=4.3##        out variations in its workload. This is an integer between
##V>=4.3##        1 and 50.
##V>=4.3##        Default: 1.
##V>=4.3##        @since 2.5.0 and OCaml 4.03.0 *)
##V>=4.3##

##V>=4.8##    custom_major_ratio : int;
##V>=4.8##    (** Target ratio of floating garbage to major heap size for
##V>=4.8##        out-of-heap memory held by custom values located in the major
##V>=4.8##        heap. The GC speed is adjusted to try to use this much memory
##V>=4.8##        for dead values that are not yet collected. Expressed as a
##V>=4.8##        percentage of major heap size. The default value keeps the
##V>=4.8##        out-of-heap floating garbage about the same size as the
##V>=4.8##        in-heap overhead.
##V>=4.8##        Note: this only applies to values allocated with
##V>=4.8##        [caml_alloc_custom_mem] (e.g. bigarrays).
##V>=4.8##        Default: 44.
##V>=4.8##        @since 2.10.0 and OCaml 4.08.0 *)

##V>=4.8##    custom_minor_ratio : int;
##V>=4.8##    (** Bound on floating garbage for out-of-heap memory held by
##V>=4.8##        custom values in the minor heap. A minor GC is triggered when
##V>=4.8##        this much memory is held by custom values located in the minor
##V>=4.8##        heap. Expressed as a percentage of minor heap size.
##V>=4.8##        Note: this only applies to values allocated with
##V>=4.8##        [caml_alloc_custom_mem] (e.g. bigarrays).
##V>=4.8##        Default: 100.
##V>=4.8##        @since 2.10.0 and OCaml 4.08.0 *)

##V>=4.8##    custom_minor_max_size : int;
##V>=4.8##    (** Maximum amount of out-of-heap memory for each custom value
##V>=4.8##        allocated in the minor heap. When a custom value is allocated
##V>=4.8##        on the minor heap and holds more than this many bytes, only
##V>=4.8##        this value is counted against [custom_minor_ratio] and the
##V>=4.8##        rest is directly counted against [custom_major_ratio].
##V>=4.8##        Note: this only applies to values allocated with
##V>=4.8##        [caml_alloc_custom_mem] (e.g. bigarrays).
##V>=4.8##        Default: 8192 bytes.
##V>=4.8##        @since 2.10.0 and OCaml 4.08.0 *)
##V>=4.8##
  }
(** The GC parameters are given as a [control] record.  Note that
    these parameters can also be initialised by setting the
    OCAMLRUNPARAM environment variable.  See the documentation of
    ocamlrun. *)

external stat : unit -> stat = "caml_gc_stat"
(** Return the current values of the memory management counters in a
    [stat] record.  This function examines every heap block to get the
    statistics. *)

external quick_stat : unit -> stat = "caml_gc_quick_stat"
(** Same as [stat] except that [live_words], [live_blocks], [free_words],
    [free_blocks], [largest_free], and [fragments] are set to 0.  This
    function is much faster than [stat] because it does not need to go
    through the heap. *)

external counters : unit -> float * float * float = "caml_gc_counters"
(** Return [(minor_words, promoted_words, major_words)].  This function
    is as fast at [quick_stat]. *)

##V>=4.4##external minor_words : unit -> (float [@unboxed])
##V>=4.4##  = "caml_gc_minor_words" "caml_gc_minor_words_unboxed"
##V=4.4##     [@@noalloc]
##V>=4.4##(** Number of words allocated in the minor heap since the program was
##V>=4.4##    started. This number is accurate in byte-code programs, but only an
##V>=4.4##    approximation in programs compiled to native code.
##V>=4.4##
##V>=4.4##    In native code this function does not allocate.
##V>=4.4##
##V>=4.4##    @since 2.5.3 and OCaml 4.04 *)

external get : unit -> control = "caml_gc_get"
(** Return the current values of the GC parameters in a [control] record. *)

external set : control -> unit = "caml_gc_set"
(** [set r] changes the GC parameters according to the [control] record [r].
    The normal usage is: [Gc.set { (Gc.get()) with Gc.verbose = 0x00d }] *)

external minor : unit -> unit = "caml_gc_minor"
(** Trigger a minor collection. *)

external major_slice : int -> int = "caml_gc_major_slice"
(** Do a minor collection and a slice of major collection.  The argument
    is the size of the slice, 0 to use the automatically-computed
    slice size.  In all cases, the result is the computed slice size. *)

external major : unit -> unit = "caml_gc_major"
(** Do a minor collection and finish the current major collection cycle. *)

external full_major : unit -> unit = "caml_gc_full_major"
(** Do a minor collection, finish the current major collection cycle,
    and perform a complete new cycle.  This will collect all currently
    unreachable blocks. *)

external compact : unit -> unit = "caml_gc_compaction"
(** Perform a full major collection and compact the heap.  Note that heap
    compaction is a lengthy operation. *)

val print_stat : _ BatInnerIO.output -> unit
(** Print the current values of the memory management counters (in
    human-readable form) into the channel argument. *)

val allocated_bytes : unit -> float
(** Return the total number of bytes allocated since the program was
    started.  It is returned as a [float] to avoid overflow problems
    with [int] on 32-bit machines. *)

##V>=4.3##external get_minor_free : unit -> int = "caml_get_minor_free"
##V=4.3##          [@@noalloc]
##V=4.4##          [@@noalloc]
##V>=4.3##(** Return the current size of the free space inside the minor heap.
##V>=4.3##    @since 2.5.0 and OCaml 4.03.0 *)

##V>=4.3####V<multicore##external get_bucket : int -> int = "caml_get_major_bucket" [@@noalloc]
##V>=4.3####V<multicore##(** [get_bucket n] returns the current size of the [n]-th future bucket
##V>=4.3####V<multicore##    of the GC smoothing system. The unit is one millionth of a full GC.
##V>=4.3####V<multicore##    Raise [Invalid_argument] if [n] is negative, return 0 if n is larger
##V>=4.3####V<multicore##    than the smoothing window.
##V>=4.3####V<multicore##    @since 2.5.0 and OCaml 4.03.0 *)

##V>=4.3####V<multicore##external get_credit : unit -> int = "caml_get_major_credit" [@@noalloc]
##V>=4.3####V<multicore##(** [get_credit ()] returns the current size of the "work done in advance"
##V>=4.3####V<multicore##    counter of the GC smoothing system. The unit is one millionth of a
##V>=4.3####V<multicore##    full GC.
##V>=4.3####V<multicore##    @since 2.5.0 and OCaml 4.03.0 *)

##V>=4.3####V<multicore##external huge_fallback_count : unit -> int = "caml_gc_huge_fallback_count"
##V>=4.3####V<multicore##(** Return the number of times we tried to map huge pages and had to fall
##V>=4.3####V<multicore##    back to small pages. This is always 0 if [OCAMLRUNPARAM] contains [H=1].
##V>=4.3####V<multicore##    @since 2.5.0 and OCaml 4.03.0 *)

val finalise : ('a -> unit) -> 'a -> unit
(** [finalise f v] registers [f] as a finalisation function for [v].
    [v] must be heap-allocated.  [f] will be called with [v] as
    argument at some point between the first time [v] becomes unreachable
    and the time [v] is collected by the GC.  Several functions can
    be registered for the same value, or even several instances of the
    same function.  Each instance will be called once (or never,
    if the program terminates before [v] becomes unreachable).

    The GC will call the finalisation functions in the order of
    deallocation.  When several values become unreachable at the
    same time (i.e. during the same GC cycle), the finalisation
    functions will be called in the reverse order of the corresponding
    calls to [finalise].  If [finalise] is called in the same order
    as the values are allocated, that means each value is finalised
    before the values it depends upon.  Of course, this becomes
    false if additional dependencies are introduced by assignments.

    Anything reachable from the closure of finalisation functions
    is considered reachable, so the following code will not work
    as expected:
    - [ let v = ... in Gc.finalise (fun x -> ...) v ]

    Instead you should write:
    - [ let f = fun x -> ... ;; let v = ... in Gc.finalise f v ]


    The [f] function can use all features of OCaml, including
    assignments that make the value reachable again.  It can also
    loop forever (in this case, the other
    finalisation functions will not be called during the execution of f,
    unless it calls [finalise_release]).
    It can call [finalise] on [v] or other values to register other
    functions or even itself.  It can raise an exception; in this case
    the exception will interrupt whatever the program was doing when
    the function was called.


    [finalise] will raise [Invalid_argument] if [v] is not
    heap-allocated.  Some examples of values that are not
    heap-allocated are integers, constant constructors, booleans,
    the empty array, the empty list, the unit value.  The exact list
    of what is heap-allocated or not is implementation-dependent.
    Some constant values can be heap-allocated but never deallocated
    during the lifetime of the program, for example a list of integer
    constants; this is also implementation-dependent.
    You should also be aware that compiler optimisations may duplicate
    some immutable values, for example floating-point numbers when
    stored into arrays, so they can be finalised and collected while
    another copy is still in use by the program.


    The results of calling {!String.make}, {!String.create},
    {!Array.make}, and {!Pervasives.ref} are guaranteed to be
    heap-allocated and non-constant except when the length argument is [0].
*)

##V>=4.4##val finalise_last : (unit -> unit) -> 'a -> unit
##V>=4.4##(** same as {!finalise} except the value is not given as argument. So
##V>=4.4##    you can't use the given value for the computation of the
##V>=4.4##    finalisation function. The benefit is that the function is called
##V>=4.4##    after the value is unreachable for the last time instead of the
##V>=4.4##    first time. So contrary to {!finalise} the value will never be
##V>=4.4##    reachable again or used again. In particular every weak pointers
##V>=4.4##    and ephemerons that contained this value as key or data is unset
##V>=4.4##    before running the finalisation function. Moreover the
##V>=4.4##    finalisation function attached with `GC.finalise` are always
##V>=4.4##    called before the finalisation function attached with `GC.finalise_last`.
##V>=4.4##
##V>=4.4##    @since 2.11.0 and OCaml 4.04
##V>=4.4##*)

val finalise_release : unit -> unit
(** A finalisation function may call [finalise_release] to tell the
    GC that it can launch the next finalisation function without waiting
    for the current one to return. *)

type alarm = Gc.alarm
(** An alarm is a piece of data that calls a user function at the end of
    each major GC cycle.  The following functions are provided to create
    and delete alarms. *)

val create_alarm : (unit -> unit) -> alarm
(** [create_alarm f] will arrange for [f] to be called at the end of each
    major GC cycle, starting with the current cycle or the next one.
    A value of type [alarm] is returned that you can
    use to call [delete_alarm]. *)

val delete_alarm : alarm -> unit
  (** [delete_alarm a] will stop the calls to the function associated
      to [a].  Calling [delete_alarm a] again has no effect. *)

##V>=4.11####V<5.0##external eventlog_pause : unit -> unit = "caml_eventlog_pause"
##V>=5.0##val                eventlog_pause : unit -> unit
##V>=4.11##(** [eventlog_pause ()] will pause the collection of traces in the
##V>=4.11##   runtime.
##V>=4.11##   Traces are collected if the program is linked to the instrumented runtime
##V>=4.11##   and started with the environment variable OCAML_EVENTLOG_ENABLED.
##V>=4.11##   Events are flushed to disk after pausing, and no new events will be
##V>=4.11##   recorded until [eventlog_resume] is called. *)
##V>=4.11##
##V>=4.11####V<5.0##external eventlog_resume : unit -> unit = "caml_eventlog_resume"
##V>=5.0##val                eventlog_resume : unit -> unit
##V>=4.11##(** [eventlog_resume ()] will resume the collection of traces in the
##V>=4.11##   runtime.
##V>=4.11##   Traces are collected if the program is linked to the instrumented runtime
##V>=4.11##   and started with the environment variable OCAML_EVENTLOG_ENABLED.
##V>=4.11##   This call can be used after calling [eventlog_pause], or if the program
##V>=4.11##   was started with OCAML_EVENTLOG_ENABLED=p. (which pauses the collection of
##V>=4.11##   traces before the first event.) *)
##V>=4.11##
##V>=4.11##
##V>=4.11##(** [Memprof] is a sampling engine for allocated memory words. Every
##V>=4.11##   allocated word has a probability of being sampled equal to a
##V>=4.11##   configurable sampling rate. Once a block is sampled, it becomes
##V>=4.11##   tracked. A tracked block triggers a user-defined callback as soon
##V>=4.11##   as it is allocated, promoted or deallocated.
##V>=4.11##
##V>=4.11##   Since blocks are composed of several words, a block can potentially
##V>=4.11##   be sampled several times. If a block is sampled several times, then
##V>=4.11##   each of the callback is called once for each event of this block:
##V>=4.11##   the multiplicity is given in the [n_samples] field of the
##V>=4.11##   [allocation] structure.
##V>=4.11##
##V>=4.11##   This engine makes it possible to implement a low-overhead memory
##V>=4.11##   profiler as an OCaml library.
##V>=4.11##
##V>=4.11##   Note: this API is EXPERIMENTAL. It may change without prior
##V>=4.11##   notice. *)
##V>=4.11##module Memprof :
##V>=4.11##  sig
##V>=5.2##     type t = Gc.Memprof.t
##V>=4.12##    type allocation_source = Gc.Memprof.allocation_source = Normal | Marshal | Custom
##V>=4.11##    type allocation = Gc.Memprof.allocation = private
##V>=4.11##      { n_samples : int;
##V>=4.11##        (** The number of samples in this block (>= 1). *)
##V>=4.11##
##V>=4.11##        size : int;
##V>=4.11##        (** The size of the block, in words, excluding the header. *)
##V>=4.11##
##V>=4.11####V<4.12##        unmarshalled : bool;
##V>=4.11####V<4.12##        (** Whether the block comes from unmarshalling. *)
##V>=4.12##        source : allocation_source;
##V>=4.12##        (** The type of the allocation. *)
##V>=4.11##
##V>=4.11##        callstack : Printexc.raw_backtrace
##V>=4.11##        (** The callstack for the allocation. *)
##V>=4.11##      }
##V>=4.11##    (** The type of metadata associated with allocations. This is the
##V>=4.11##       type of records passed to the callback triggered by the
##V>=4.11##       sampling of an allocation. *)
##V>=4.11##
##V>=4.11##    type ('minor, 'major) tracker =
##V>=4.11##        ('minor, 'major) Gc.Memprof.tracker = {
##V>=4.11##      alloc_minor: allocation -> 'minor option;
##V>=4.11##      alloc_major: allocation -> 'major option;
##V>=4.11##      promote: 'minor -> 'major option;
##V>=4.11##      dealloc_minor: 'minor -> unit;
##V>=4.11##      dealloc_major: 'major -> unit;
##V>=4.11##    }
##V>=4.11##    (**
##V>=4.11##       A [('minor, 'major) tracker] describes how memprof should track
##V>=4.11##       sampled blocks over their lifetime, keeping a user-defined piece
##V>=4.11##       of metadata for each of them: ['minor] is the type of metadata
##V>=4.11##       to keep for minor blocks, and ['major] the type of metadata
##V>=4.11##       for major blocks.
##V>=4.11##
##V>=4.11##       If an allocation-tracking or promotion-tracking function returns [None],
##V>=4.11##       memprof stops tracking the corresponding value.
##V>=4.11##     *)
##V>=4.11##
##V>=4.11##    val null_tracker: ('minor, 'major) tracker
##V>=4.11##    (** Default callbacks simply return [None] or [()] *)
##V>=4.11##
##V>=4.11##    val start :
##V>=4.11##      sampling_rate:float ->
##V>=4.11##      ?callstack_size:int ->
##V>=4.11##      ('minor, 'major) tracker ->
##V>=4.11####V<5.2##      unit
##V>=5.2##      t
##V>=4.11##    (** Start the sampling with the given parameters. Fails if
##V>=4.11##       sampling is already active.
##V>=4.11##
##V>=4.11##       The parameter [sampling_rate] is the sampling rate in samples
##V>=4.11##       per word (including headers). Usually, with cheap callbacks, a
##V>=4.11##       rate of 1e-4 has no visible effect on performance, and 1e-3
##V>=4.11##       causes the program to run a few percent slower
##V>=4.11##
##V>=4.11##       The parameter [callstack_size] is the length of the callstack
##V>=4.11##       recorded at every sample. Its default is [max_int].
##V>=4.11##
##V>=4.11##       The parameter [tracker] determines how to track sampled blocks
##V>=4.11##       over their lifetime in the minor and major heap.
##V>=4.11##
##V>=4.11##       Sampling is temporarily disabled when calling a callback
##V>=4.11##       for the current thread. So they do not need to be reentrant if
##V>=4.11##       the program is single-threaded. However, if threads are used,
##V>=4.11##       it is possible that a context switch occurs during a callback,
##V>=4.11##       in this case the callback functions must be reentrant.
##V>=4.11##
##V>=4.11##       Note that the callback can be postponed slightly after the
##V>=4.11##       actual event. The callstack passed to the callback is always
##V>=4.11##       accurate, but the program state may have evolved.
##V>=4.11##
##V>=4.11##       Calling [Thread.exit] in a callback is currently unsafe and can
##V>=4.11##       result in undefined behavior. *)
##V>=4.11##
##V>=4.11##    val stop : unit -> unit
##V>=4.11##    (** Stop the sampling. Fails if sampling is not active.
##V>=4.11##
##V>=4.11##        This function does not allocate memory, but tries to run the
##V>=4.11##        postponed callbacks for already allocated memory blocks (of
##V>=4.11##        course, these callbacks may allocate).
##V>=4.11##
##V>=4.11##        All the already tracked blocks are discarded.
##V>=4.11##
##V>=4.11##        Calling [stop] when a callback is running can lead to
##V>=4.11##        callbacks not being called even though some events happened. *)
##V>=5.2##     val discard : t -> unit
##V>=4.11##end
