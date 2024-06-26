(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the GNU Library General Public License, with    *)
(*  the special exception on linking described in file ../LICENSE.     *)
(*                                                                     *)
(***********************************************************************)

(** Byte sequence operations.

   A byte sequence is a mutable data structure that contains a
   fixed-length sequence of bytes. Each byte can be indexed in
   constant time for reading or writing.

   Given a byte sequence [s] of length [l], we can access each of the
   [l] bytes of [s] via its index in the sequence. Indexes start at
   [0], and we will call an index valid in [s] if it falls within the
   range [[0...l-1]] (inclusive). A position is the point between two
   bytes or at the beginning or end of the sequence.  We call a
   position valid in [s] if it falls within the range [[0...l]]
   (inclusive). Note that the byte at index [n] is between positions
   [n] and [n+1].

   Two parameters [start] and [len] are said to designate a valid
   range of [s] if [len >= 0] and [start] and [start+len] are valid
   positions in [s].

   Byte sequences can be modified in place, for instance via the [set]
   and [blit] functions described below.  See also strings (module
   {!String}), which are almost the same data structure, but cannot be
   modified in place.

   Bytes are represented by the OCaml type [char].

   @since Batteries 2.3.0 and OCaml 4.02.0
 *)

##V<4.2##type t = string
##V>=4.2##type t = bytes
(** An alias for the type of byte sequences. *)

##V<4.4##external length : t -> int = "%string_length"
##V>=4.4##external length : t -> int = "%bytes_length"
(** Return the length (number of t) of the argument. *)

##V<4.4##external get : t -> int -> char = "%string_safe_get"
##V>=4.4##external get : t -> int -> char = "%bytes_safe_get"
(** [get s n] returns the byte at index [n] in argument [s].

    Raise [Invalid_argument] if [n] not a valid index in [s]. *)

##V<4.4##external set : t -> int -> char -> unit = "%string_safe_set"
##V>=4.4##external set : t -> int -> char -> unit = "%bytes_safe_set"
(** [set s n c] modifies [s] in place, replacing the byte at index [n]
    with [c].

    Raise [Invalid_argument] if [n] is not a valid index in [s]. *)

##V<4.4##external create : int -> t = "caml_create_string"
##V>=4.4##external create : int -> t = "caml_create_bytes"
(** [create n] returns a new byte sequence of length [n]. The
    sequence is uninitialized and contains arbitrary bytes.

    Raise [Invalid_argument] if [n < 0] or [n > ]{!Sys.max_string_length}. *)

val make : int -> char -> t
(** [make n c] returns a new byte sequence of length [n], filled with
    the byte [c].

    Raise [Invalid_argument] if [n < 0] or [n > ]{!Sys.max_string_length}. *)

val init : int -> (int -> char) -> t
(** [Bytes.init n f] returns a fresh byte sequence of length [n], with
    character [i] initialized to the result of [f i] (in increasing
    index order).

    Raise [Invalid_argument] if [n < 0] or [n > ]{!Sys.max_string_length}. *)

val empty : t
(** A byte sequence of size 0. *)

val copy : t -> t
(** Return a new byte sequence that contains the same bytes as the
    argument. *)

val of_string : string -> t
(** Return a new byte sequence that contains the same bytes as the
    given string. *)

val to_string : t -> string
(** Return a new string that contains the same bytes as the given byte
    sequence. *)

val sub : t -> int -> int -> t
(** [sub s start len] returns a new byte sequence of length [len],
    containing the subsequence of [s] that starts at position [start]
    and has length [len].

    Raise [Invalid_argument] if [start] and [len] do not designate a
    valid range of [s]. *)

val sub_string : t -> int -> int -> string
(** Same as [sub] but return a string instead of a byte sequence. *)

val extend : t -> int -> int -> t
(** [extend s left right] returns a new byte sequence that contains
    the bytes of [s], with [left] uninitialized bytes prepended and
    [right] uninitialized bytes appended to it. If [left] or [right]
    is negative, then bytes are removed (instead of appended) from
    the corresponding side of [s].

    Raise [Invalid_argument] if the result length is negative or
    longer than {!Sys.max_string_length} bytes. *)

val fill : t -> int -> int -> char -> unit
(** [fill s start len c] modifies [s] in place, replacing [len]
    characters with [c], starting at [start].

    Raise [Invalid_argument] if [start] and [len] do not designate a
    valid range of [s]. *)

val blit : t -> int -> t -> int -> int -> unit
(** [blit src srcoff dst dstoff len] copies [len] bytes from sequence
    [src], starting at index [srcoff], to sequence [dst], starting at
    index [dstoff]. It works correctly even if [src] and [dst] are the
    same byte sequence, and the source and destination intervals
    overlap.

    Raise [Invalid_argument] if [srcoff] and [len] do not
    designate a valid range of [src], or if [dstoff] and [len]
    do not designate a valid range of [dst]. *)

val blit_string : string -> int -> t -> int -> int -> unit
(** [blit_string src srcoff dst dstoff len] copies [len] bytes from string
    [src], starting at index [srcoff], to byte sequence [dst],
    starting at index [dstoff].

    Raise [Invalid_argument] if [srcoff] and [len] do not
    designate a valid range of [src], or if [dstoff] and [len]
    do not designate a valid range of [dst]. *)

val concat : t -> t list -> t
(** [concat sep sl] concatenates the list of byte sequences [sl],
    inserting the separator byte sequence [sep] between each, and
    returns the result as a new byte sequence.

    Raise [Invalid_argument] if the result is longer than
    {!Sys.max_string_length} bytes. *)

val cat : t -> t -> t
(** [cat s1 s2] concatenates [s1] and [s2] and returns the result
     as new byte sequence.

    Raise [Invalid_argument] if the result is longer than
    {!Sys.max_string_length} bytes. *)

val iter : (char -> unit) -> t -> unit
(** [iter f s] applies function [f] in turn to all the bytes of [s].
    It is equivalent to [f (get s 0); f (get s 1); ...; f (get s
    (length s - 1)); ()]. *)

val iteri : (int -> char -> unit) -> t -> unit
(** Same as {!Bytes.iter}, but the function is applied to the index of
    the byte as first argument and the byte itself as second
    argument. *)

val map : (char -> char) -> t -> t
(** [map f s] applies function [f] in turn to all the bytes of [s]
    (in increasing index order) and stores the resulting bytes in
    a new sequence that is returned as the result. *)

val mapi : (int -> char -> char) -> t -> t
(** [mapi f s] calls [f] with each character of [s] and its
    index (in increasing index order) and stores the resulting bytes
    in a new sequence that is returned as the result. *)

val fold_left : ('a -> char -> 'a) -> 'a -> t -> 'a
(** [fold_left f x s] computes
    [f (... (f (f x (get s 0)) (get s 1)) ...) (get s (n-1))],
    where [n] is the length of [s].
    @since 3.4.0 *)

val fold_right : (char -> 'a -> 'a) -> t -> 'a -> 'a
(** [fold_right f s x] computes
    [f (get s 0) (f (get s 1) ( ... (f (get s (n-1)) x) ...))],
    where [n] is the length of [s].
    @since 3.4.0 *)

val for_all : (char -> bool) -> t -> bool
(** [for_all p s] checks if all characters in [s] satisfy the predicate [p].
    @since 3.4.0 *)

val exists : (char -> bool) -> t -> bool
(** [exists p s] checks if at least one character of [s] satisfies
    the predicate [p].
    @since 3.4.0 *)

val trim : t -> t
(** Return a copy of the argument, without leading and trailing
    whitespace. The bytes regarded as whitespace are the ASCII
    characters [' '], ['\012'], ['\n'], ['\r'], and ['\t']. *)

val escaped : t -> t
(** Return a copy of the argument, with special characters represented
    by escape sequences, following the lexical conventions of OCaml.

    Raise [Invalid_argument] if the result is longer than
    {!Sys.max_string_length} bytes. *)

val index : t -> char -> int
(** [index s c] returns the index of the first occurrence of byte [c]
    in [s].

    Raise [Not_found] if [c] does not occur in [s]. *)

val index_opt: t -> char -> int option
(** [index_opt s c] returns the index of the first occurrence of byte [c]
    in [s] or [None] if [c] does not occur in [s].
    @since 2.7.0 *)

val rindex : t -> char -> int
(** [rindex s c] returns the index of the last occurrence of byte [c]
    in [s].

    Raise [Not_found] if [c] does not occur in [s]. *)

val rindex_opt: t -> char -> int option
(** [rindex_opt s c] returns the index of the last occurrence of byte [c]
    in [s] or [None] if [c] does not occur in [s].
    @since 2.7.0 *)

val index_from : t -> int -> char -> int
(** [index_from s i c] returns the index of the first occurrence of
    byte [c] in [s] after position [i].  [Bytes.index s c] is
    equivalent to [Bytes.index_from s 0 c].

    Raise [Invalid_argument] if [i] is not a valid position in [s].
    Raise [Not_found] if [c] does not occur in [s] after position [i]. *)

val index_from_opt: t -> int -> char -> int option
(** [index_from _opts i c] returns the index of the first occurrence of
    byte [c] in [s] after position [i] or [None] if [c] does not occur in [s] after position [i].
    [Bytes.index_opt s c] is equivalent to [Bytes.index_from_opt s 0 c].

    Raise [Invalid_argument] if [i] is not a valid position in [s].
    @since 2.7.0 *)

val rindex_from : t -> int -> char -> int
(** [rindex_from s i c] returns the index of the last occurrence of
    byte [c] in [s] before position [i+1].  [rindex s c] is equivalent
    to [rindex_from s (Bytes.length s - 1) c].

    Raise [Invalid_argument] if [i+1] is not a valid position in [s].
    Raise [Not_found] if [c] does not occur in [s] before position [i+1]. *)

val rindex_from_opt: t -> int -> char -> int option
(** [rindex_from_opt s i c] returns the index of the last occurrence
    of byte [c] in [s] before position [i+1] or [None] if [c] does not
    occur in [s] before position [i+1].  [rindex_opt s c] is equivalent to
    [rindex_from s (Bytes.length s - 1) c].

    Raise [Invalid_argument] if [i+1] is not a valid position in [s].
    @since 2.7.0 *)

val starts_with: prefix:t -> t -> bool
(** [starts_with ~prefix s] is [true] if and only if [s] starts with
    [prefix].
    @since 3.4.0 *)

val ends_with: suffix:t -> t -> bool
(** [ends_with ~suffix s] is [true] if and only if [s] ends with [suffix].
    @since 3.4.0 *)

val contains : t -> char -> bool
(** [contains s c] tests if byte [c] appears in [s]. *)

val contains_from : t -> int -> char -> bool
(** [contains_from s start c] tests if byte [c] appears in [s] after
    position [start].  [contains s c] is equivalent to [contains_from
    s 0 c].

    Raise [Invalid_argument] if [start] is not a valid position in [s]. *)

val rcontains_from : t -> int -> char -> bool
(** [rcontains_from s stop c] tests if byte [c] appears in [s] before
    position [stop+1].

    Raise [Invalid_argument] if [stop < 0] or [stop+1] is not a valid
    position in [s]. *)

##V<5##val uppercase : t -> t
##V<5##(** Return a copy of the argument, with all lowercase letters
##V<5##    translated to uppercase, including accented letters of the ISO
##V<5##    Latin-1 (8859-1) character set. *)

##V<5##val lowercase : t -> t
##V<5##(** Return a copy of the argument, with all uppercase letters
##V<5##    translated to lowercase, including accented letters of the ISO
##V<5##    Latin-1 (8859-1) character set. *)

##V<5##val capitalize : t -> t
##V<5##(** Return a copy of the argument, with the first byte set to
##V<5##    uppercase. *)

##V<5##val uncapitalize : t -> t
##V<5##(** Return a copy of the argument, with the first byte set to
##V<5##    lowercase. *)

val uppercase_ascii : t -> t
(** Return a copy of the argument, with all lowercase letters
   translated to uppercase, using the US-ASCII character set.
   @since 2.5.0 *)

val lowercase_ascii : t -> t
(** Return a copy of the argument, with all uppercase letters
   translated to lowercase, using the US-ASCII character set.
   @since 2.5.0 *)

val capitalize_ascii : t -> t
(** Return a copy of the argument, with the first character set to uppercase,
   using the US-ASCII character set.
   @since 2.5.0 *)

val uncapitalize_ascii : t -> t
(** Return a copy of the argument, with the first character set to lowercase,
   using the US-ASCII character set.
   @since 2.5.0 *)

val compare: t -> t -> int
(** The comparison function for byte sequences, with the same
    specification as {!Pervasives.compare}.  Along with the type [t],
    this function [compare] allows the module [Bytes] to be passed as
    argument to the functors {!Set.Make} and {!Map.Make}. *)

val equal: t -> t -> bool
(** The equality function for byte sequences.
    @since 2.5.0 *)

val split_on_char: char -> t -> t list
(** [split_on_char sep s] returns the list of all (possibly empty)
    subsequences of [s] that are delimited by the [sep] character.

    The function's output is specified by the following invariants:

    - The list is not empty.
    - Concatenating its elements using [sep] as a separator returns a
      byte sequence equal to the input ([Bytes.concat (Bytes.make 1 sep)
      (Bytes.split_on_char sep s) = s]).
    - No byte sequence in the result contains the [sep] character.
    @since 3.4.0
*)

(** {4 Unsafe conversions (for advanced users)}

    This section describes unsafe, low-level conversion functions
    between [bytes] and [string]. They do not copy the internal data;
    used improperly, they can break the immutability invariant on
    strings provided by the [-safe-string] option. They are available for
    expert library authors, but for most purposes you should use the
    always-correct {!Bytes.to_string} and {!Bytes.of_string} instead.
*)

val unsafe_to_string : t -> string
(** Unsafely convert a byte sequence into a string.

    To reason about the use of [unsafe_to_string], it is convenient to
    consider an "ownership" discipline. A piece of code that
    manipulates some data "owns" it; there are several disjoint ownership
    modes, including:
    - Unique ownership: the data may be accessed and mutated
    - Shared ownership: the data has several owners, that may only
      access it, not mutate it.

    Unique ownership is linear: passing the data to another piece of
    code means giving up ownership (we cannot write the
    data again). A unique owner may decide to make the data shared
    (giving up mutation rights on it), but shared data may not become
    uniquely-owned again.

   [unsafe_to_string s] can only be used when the caller owns the byte
   sequence [s] -- either uniquely or as shared immutable data. The
   caller gives up ownership of [s], and gains ownership of the
   returned string.

   There are two valid use-cases that respect this ownership
   discipline:

   1. Creating a string by initializing and mutating a byte sequence
   that is never changed after initialization is performed.

   {[
let string_init len f : string =
  let s = Bytes.create len in
  for i = 0 to len - 1 do Bytes.set s i (f i) done;
  Bytes.unsafe_to_string s
   ]}

   This function is safe because the byte sequence [s] will never be
   accessed or mutated after [unsafe_to_string] is called. The
   [string_init] code gives up ownership of [s], and returns the
   ownership of the resulting string to its caller.

   Note that it would be unsafe if [s] was passed as an additional
   parameter to the function [f] as it could escape this way and be
   mutated in the future -- [string_init] would give up ownership of
   [s] to pass it to [f], and could not call [unsafe_to_string]
   safely.

   We have provided the {!String.init}, {!String.map} and
   {!String.mapi} functions to cover most cases of building
   new strings. You should prefer those over [to_string] or
   [unsafe_to_string] whenever applicable.

   2. Temporarily giving ownership of a byte sequence to a function
   that expects a uniquely owned string and returns ownership back, so
   that we can mutate the sequence again after the call ended.

   {[
let bytes_length (s : bytes) =
  String.length (Bytes.unsafe_to_string s)
   ]}

   In this use-case, we do not promise that [s] will never be mutated
   after the call to [bytes_length s]. The {!String.length} function
   temporarily borrows unique ownership of the byte sequence
   (and sees it as a [string]), but returns this ownership back to
   the caller, which may assume that [s] is still a valid byte
   sequence after the call. Note that this is only correct because we
   know that {!String.length} does not capture its argument -- it could
   escape by a side-channel such as a memoization combinator.

   The caller may not mutate [s] while the string is borrowed (it has
   temporarily given up ownership). This affects concurrent programs,
   but also higher-order functions: if [String.length] returned
   a closure to be called later, [s] should not be mutated until this
   closure is fully applied and returns ownership.
*)

val unsafe_of_string : string -> t
(** Unsafely convert a shared string to a byte sequence that should
    not be mutated.

    The same ownership discipline that makes [unsafe_to_string]
    correct applies to [unsafe_of_string]: you may use it if you were
    the owner of the [string] value, and you will own the return
    [bytes] in the same mode.

    In practice, unique ownership of string values is extremely
    difficult to reason about correctly. You should always assume
    strings are shared, never uniquely owned.

    For example, string literals are implicitly shared by the
    compiler, so you never uniquely own them.

    {[
let incorrect = Bytes.unsafe_of_string "hello"
let s = Bytes.of_string "hello"
    ]}

    The first declaration is incorrect, because the string literal
    ["hello"] could be shared by the compiler with other parts of the
    program, and mutating [incorrect] is a bug. You must always use
    the second version, which performs a copy and is thus correct.

    Assuming unique ownership of strings that are not string
    literals, but are (partly) built from string literals, is also
    incorrect. For example, mutating [unsafe_of_string ("foo" ^ s)]
    could mutate the shared string ["foo"] -- assuming a rope-like
    representation of strings. More generally, functions operating on
    strings will assume shared ownership, they do not preserve unique
    ownership. It is thus incorrect to assume unique ownership of the
    result of [unsafe_of_string].

    The only case we have reasonable confidence is safe is if the
    produced [bytes] is shared -- used as an immutable byte
    sequence. This is possibly useful for incremental migration of
    low-level programs that manipulate immutable sequences of bytes
    (for example {!Marshal.from_bytes}) and previously used the
    [string] type for this purpose.
*)

##V>=4.07##(** {1 Iterators} *)
##V>=4.07##
##V>=4.07##val to_seq : t -> char Seq.t
##V>=4.07##(** Iterate on the string, in increasing index order. Modifications of the
##V>=4.07##    string during iteration will be reflected in the iterator.
##V>=4.07##    @since 2.10.0 and OCaml 4.07 *)

##V>=4.07##val to_seqi : t -> (int * char) Seq.t
##V>=4.07##(** Iterate on the string, in increasing order, yielding indices along chars
##V>=4.07##    @since 2.10.0 and OCaml 4.07 *)

##V>=4.07##val of_seq : char Seq.t -> t
##V>=4.07##(** Create a string from the generator
##V>=4.07##    @since 2.10.0 and OCaml 4.07 *)

##V>=4.14##(** {1:utf UTF codecs and validations}
##V>=4.14##
##V>=4.14##    @since 4.14 *)
##V>=4.14##
##V>=4.14##(** {2:utf_8 UTF-8} *)

##V>=4.14##val get_utf_8_uchar : t -> int -> Uchar.utf_decode
##V>=4.14##(** [get_utf_8_uchar b i] decodes an UTF-8 character at index [i] in
##V>=4.14##    [b]. *)

##V>=4.14##val set_utf_8_uchar : t -> int -> Uchar.t -> int
##V>=4.14##(** [set_utf_8_uchar b i u] UTF-8 encodes [u] at index [i] in [b]
##V>=4.14##    and returns the number of bytes [n] that were written starting
##V>=4.14##    at [i]. If [n] is [0] there was not enough space to encode [u]
##V>=4.14##    at [i] and [b] was left untouched. Otherwise a new character can
##V>=4.14##    be encoded at [i + n]. *)

##V>=4.14##val is_valid_utf_8 : t -> bool
##V>=4.14##(** [is_valid_utf_8 b] is [true] if and only if [b] contains valid
##V>=4.14##    UTF-8 data. *)

##V>=4.14##(** {2:utf_16be UTF-16BE} *)

##V>=4.14##val get_utf_16be_uchar : t -> int -> Uchar.utf_decode
##V>=4.14##(** [get_utf_16be_uchar b i] decodes an UTF-16BE character at index
##V>=4.14##    [i] in [b]. *)

##V>=4.14##val set_utf_16be_uchar : t -> int -> Uchar.t -> int
##V>=4.14##(** [set_utf_16be_uchar b i u] UTF-16BE encodes [u] at index [i] in [b]
##V>=4.14##    and returns the number of bytes [n] that were written starting
##V>=4.14##    at [i]. If [n] is [0] there was not enough space to encode [u]
##V>=4.14##    at [i] and [b] was left untouched. Otherwise a new character can
##V>=4.14##    be encoded at [i + n]. *)

##V>=4.14##val is_valid_utf_16be : t -> bool
##V>=4.14##(** [is_valid_utf_16be b] is [true] if and only if [b] contains valid
##V>=4.14##    UTF-16BE data. *)

##V>=4.14##(** {2:utf_16le UTF-16LE} *)

##V>=4.14##val get_utf_16le_uchar : t -> int -> Uchar.utf_decode
##V>=4.14##(** [get_utf_16le_uchar b i] decodes an UTF-16LE character at index
##V>=4.14##    [i] in [b]. *)

##V>=4.14##val set_utf_16le_uchar : t -> int -> Uchar.t -> int
##V>=4.14##(** [set_utf_16le_uchar b i u] UTF-16LE encodes [u] at index [i] in [b]
##V>=4.14##    and returns the number of bytes [n] that were written starting
##V>=4.14##    at [i]. If [n] is [0] there was not enough space to encode [u]
##V>=4.14##    at [i] and [b] was left untouched. Otherwise a new character can
##V>=4.14##    be encoded at [i + n]. *)

##V>=4.14##val is_valid_utf_16le : t -> bool
##V>=4.14##(** [is_valid_utf_16le b] is [true] if and only if [b] contains valid
##V>=4.14##    UTF-16LE data. *)

##V>=4.08##(** {1 Binary encoding/decoding of integers} *)
##V>=4.08##
##V>=4.08##(** The functions in this section binary encode and decode integers to
##V>=4.08##    and from byte sequences.
##V>=4.08##
##V>=4.08##    All following functions raise [Invalid_argument] if the space
##V>=4.08##    needed at index [i] to decode or encode the integer is not
##V>=4.08##    available.
##V>=4.08##
##V>=4.08##    Little-endian (resp. big-endian) encoding means that least
##V>=4.08##    (resp. most) significant bytes are stored first.  Big-endian is
##V>=4.08##    also known as network byte order.  Native-endian encoding is
##V>=4.08##    either little-endian or big-endian depending on {!Sys.big_endian}.
##V>=4.08##
##V>=4.08##    32-bit and 64-bit integers are represented by the [int32] and
##V>=4.08##    [int64] types, which can be interpreted either as signed or
##V>=4.08##    unsigned numbers.
##V>=4.08##
##V>=4.08##    8-bit and 16-bit integers are represented by the [int] type,
##V>=4.08##    which has more bits than the binary encoding.  These extra bits
##V>=4.08##    are handled as follows:
##V>=4.08##    {ul
##V>=4.08##    {- Functions that decode signed (resp. unsigned) 8-bit or 16-bit
##V>=4.08##    integers represented by [int] values sign-extend
##V>=4.08##    (resp. zero-extend) their result.}
##V>=4.08##    {- Functions that encode 8-bit or 16-bit integers represented by
##V>=4.08##    [int] values truncate their input to their least significant
##V>=4.08##    bytes.}}
##V>=4.08##*)

##V>=4.08##val get_uint8 : t -> int -> int
##V>=4.08##(** [get_uint8 b i] is [b]'s unsigned 8-bit integer starting at byte index [i].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val get_int8 : t -> int -> int
##V>=4.08##(** [get_int8 b i] is [b]'s signed 8-bit integer starting at byte index [i].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val get_uint16_ne : t -> int -> int
##V>=4.08##(** [get_uint16_ne b i] is [b]'s native-endian unsigned 16-bit integer
##V>=4.08##    starting at byte index [i].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val get_uint16_be : t -> int -> int
##V>=4.08##(** [get_uint16_be b i] is [b]'s big-endian unsigned 16-bit integer
##V>=4.08##    starting at byte index [i].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val get_uint16_le : t -> int -> int
##V>=4.08##(** [get_uint16_le b i] is [b]'s little-endian unsigned 16-bit integer
##V>=4.08##    starting at byte index [i].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val get_int16_ne : t -> int -> int
##V>=4.08##(** [get_int16_ne b i] is [b]'s native-endian signed 16-bit integer
##V>=4.08##    starting at byte index [i].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val get_int16_be : t -> int -> int
##V>=4.08##(** [get_int16_be b i] is [b]'s big-endian signed 16-bit integer
##V>=4.08##    starting at byte index [i].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val get_int16_le : t -> int -> int
##V>=4.08##(** [get_int16_le b i] is [b]'s little-endian signed 16-bit integer
##V>=4.08##    starting at byte index [i].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val get_int32_ne : t -> int -> int32
##V>=4.08##(** [get_int32_ne b i] is [b]'s native-endian 32-bit integer
##V>=4.08##    starting at byte index [i].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val get_int32_be : t -> int -> int32
##V>=4.08##(** [get_int32_be b i] is [b]'s big-endian 32-bit integer
##V>=4.08##    starting at byte index [i].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val get_int32_le : t -> int -> int32
##V>=4.08##(** [get_int32_le b i] is [b]'s little-endian 32-bit integer
##V>=4.08##    starting at byte index [i].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val get_int64_ne : t -> int -> int64
##V>=4.08##(** [get_int64_ne b i] is [b]'s native-endian 64-bit integer
##V>=4.08##    starting at byte index [i].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val get_int64_be : t -> int -> int64
##V>=4.08##(** [get_int64_be b i] is [b]'s big-endian 64-bit integer
##V>=4.08##    starting at byte index [i].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val get_int64_le : t -> int -> int64
##V>=4.08##(** [get_int64_le b i] is [b]'s little-endian 64-bit integer
##V>=4.08##    starting at byte index [i].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val set_uint8 : t -> int -> int -> unit
##V>=4.08##(** [set_uint8 b i v] sets [b]'s unsigned 8-bit integer starting at byte index
##V>=4.08##    [i] to [v].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val set_int8 : t -> int -> int -> unit
##V>=4.08##(** [set_int8 b i v] sets [b]'s signed 8-bit integer starting at byte index
##V>=4.08##    [i] to [v].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val set_uint16_ne : t -> int -> int -> unit
##V>=4.08##(** [set_uint16_ne b i v] sets [b]'s native-endian unsigned 16-bit integer
##V>=4.08##    starting at byte index [i] to [v].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val set_uint16_be : t -> int -> int -> unit
##V>=4.08##(** [set_uint16_be b i v] sets [b]'s big-endian unsigned 16-bit integer
##V>=4.08##    starting at byte index [i] to [v].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val set_uint16_le : t -> int -> int -> unit
##V>=4.08##(** [set_uint16_le b i v] sets [b]'s little-endian unsigned 16-bit integer
##V>=4.08##    starting at byte index [i] to [v].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val set_int16_ne : t -> int -> int -> unit
##V>=4.08##(** [set_int16_ne b i v] sets [b]'s native-endian signed 16-bit integer
##V>=4.08##    starting at byte index [i] to [v].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val set_int16_be : t -> int -> int -> unit
##V>=4.08##(** [set_int16_be b i v] sets [b]'s big-endian signed 16-bit integer
##V>=4.08##    starting at byte index [i] to [v].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val set_int16_le : t -> int -> int -> unit
##V>=4.08##(** [set_int16_le b i v] sets [b]'s little-endian signed 16-bit integer
##V>=4.08##    starting at byte index [i] to [v].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val set_int32_ne : t -> int -> int32 -> unit
##V>=4.08##(** [set_int32_ne b i v] sets [b]'s native-endian 32-bit integer
##V>=4.08##    starting at byte index [i] to [v].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val set_int32_be : t -> int -> int32 -> unit
##V>=4.08##(** [set_int32_be b i v] sets [b]'s big-endian 32-bit integer
##V>=4.08##    starting at byte index [i] to [v].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val set_int32_le : t -> int -> int32 -> unit
##V>=4.08##(** [set_int32_le b i v] sets [b]'s little-endian 32-bit integer
##V>=4.08##    starting at byte index [i] to [v].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val set_int64_ne : t -> int -> int64 -> unit
##V>=4.08##(** [set_int64_ne b i v] sets [b]'s native-endian 64-bit integer
##V>=4.08##    starting at byte index [i] to [v].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val set_int64_be : t -> int -> int64 -> unit
##V>=4.08##(** [set_int64_be b i v] sets [b]'s big-endian 64-bit integer
##V>=4.08##    starting at byte index [i] to [v].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

##V>=4.08##val set_int64_le : t -> int -> int64 -> unit
##V>=4.08##(** [set_int64_le b i v] sets [b]'s little-endian 64-bit integer
##V>=4.08##    starting at byte index [i] to [v].
##V>=4.08##    @since 2.10.0 and OCaml 4.08
##V>=4.08##*)

(**/**)

(* The following is for system use only. Do not call directly. *)

##V<4.4##external unsafe_get : t -> int -> char = "%string_unsafe_get"
##V>=4.4##external unsafe_get : t -> int -> char = "%bytes_unsafe_get"

##V<4.4##external unsafe_set : t -> int -> char -> unit = "%string_unsafe_set"
##V>=4.4##external unsafe_set : t -> int -> char -> unit = "%bytes_unsafe_set"

##V<4.4##external unsafe_blit :  t -> int -> t -> int -> int -> unit = "caml_blit_string" "noalloc"
##V>=4.4##external unsafe_blit :  t -> int -> t -> int -> int -> unit = "caml_blit_bytes" [@@noalloc]

##V<4.4##external unsafe_fill : t -> int -> int -> char -> unit = "caml_fill_string" "noalloc"
##V>=4.4##external unsafe_fill:  t -> int -> int -> char -> unit = "caml_fill_bytes" [@@noalloc]

##V>=4.09##external unsafe_blit_string : string -> int -> t -> int -> int -> unit = "caml_blit_string" [@@noalloc]

##V>=5.0##val unsafe_escape : bytes -> bytes
