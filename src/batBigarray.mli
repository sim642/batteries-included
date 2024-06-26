(*
 * BatBigarray - additional and modified functions for big arrays.
 * Copyright (C) 2000 Michel Serrano
 *               2000 Xavier Leroy
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

(** Additional and modified functions for big arrays.
*)

(** Large, multi-dimensional, numerical arrays.

    This module implements multi-dimensional arrays of integers and
    floating-point numbers, thereafter referred to as ``big arrays''.
    The implementation allows efficient sharing of large numerical
    arrays between OCaml code and C or Fortran numerical libraries.

    Concerning the naming conventions, users of this module are encouraged
    to do [open Bigarray] in their source, then refer to array types and
    operations via short dot notation, e.g. [Array1.t] or [Array2.sub].

    Big arrays support all the OCaml ad-hoc polymorphic operations:
    - comparisons ([=], [<>], [<=], etc, as well as {!Pervasives.compare});
    - hashing (module [Hash]);
    - and structured input-output ({!Pervasives.output_value}
     and {!Pervasives.input_value}, as well as the functions from the
     {!Marshal} module).


    This module replaces Stdlib's
    {{:http://caml.inria.fr/pub/docs/manual-ocaml/libref/Bigarray.html}Bigarray}
    module.

    @author Michel Serrano (Base library)
    @author Xavier Leroy (Base library)
    @author David Teller
*)

(** {1 Element kinds} *)

(** Big arrays can contain elements of the following kinds:
    - IEEE single precision (32 bits) floating-point numbers
    ({!Bigarray.float32_elt}),
    - IEEE double precision (64 bits) floating-point numbers
    ({!Bigarray.float64_elt}),
    - IEEE single precision (2 * 32 bits) floating-point complex numbers
    ({!Bigarray.complex32_elt}),
    - IEEE double precision (2 * 64 bits) floating-point complex numbers
    ({!Bigarray.complex64_elt}),
    - 8-bit integers (signed or unsigned)
    ({!Bigarray.int8_signed_elt} or {!Bigarray.int8_unsigned_elt}),
    - 16-bit integers (signed or unsigned)
    ({!Bigarray.int16_signed_elt} or {!Bigarray.int16_unsigned_elt}),
    - OCaml integers (signed, 31 bits on 32-bit architectures,
    63 bits on 64-bit architectures) ({!Bigarray.int_elt}),
    - 32-bit signed integer ({!Bigarray.int32_elt}),
    - 64-bit signed integers ({!Bigarray.int64_elt}),
    - platform-native signed integers (32 bits on 32-bit architectures,
    64 bits on 64-bit architectures) ({!Bigarray.nativeint_elt}).

    Each element kind is represented at the type level by one
    of the abstract types defined below.
*)

(* The V>=4.2 lines are not necessary for typing,
   but they are necessary for the compatibility test in batteries_compattest.ml
   which are of the form:
     module _ = (BatBigarray : module type of Bigarray)
   because of the somewhat strange interpretation of strengthening in (module type of),
   we need to explicitly equate each type with its constructor *)
##V>=5.2##type float16_elt = Bigarray.float16_elt = Float16_elt
type float32_elt = Bigarray.float32_elt
##V>=4.2## = Float32_elt
type float64_elt = Bigarray.float64_elt
##V>=4.2## = Float64_elt
type complex32_elt = Bigarray.complex32_elt
##V>=4.2## = Complex32_elt
type complex64_elt = Bigarray.complex64_elt
##V>=4.2## = Complex64_elt
type int8_signed_elt = Bigarray.int8_signed_elt
##V>=4.2## = Int8_signed_elt
type int8_unsigned_elt = Bigarray.int8_unsigned_elt
##V>=4.2## = Int8_unsigned_elt
type int16_signed_elt = Bigarray.int16_signed_elt
##V>=4.2## = Int16_signed_elt
type int16_unsigned_elt = Bigarray.int16_unsigned_elt
##V>=4.2## = Int16_unsigned_elt
type int_elt = Bigarray.int_elt
##V>=4.2## = Int_elt
type int32_elt = Bigarray.int32_elt
##V>=4.2## = Int32_elt
type int64_elt = Bigarray.int64_elt
##V>=4.2## = Int64_elt
type nativeint_elt = Bigarray.nativeint_elt
##V>=4.2## = Nativeint_elt

type ('a, 'b) kind = ('a,'b) Bigarray.kind
##V>=4.2##           = Float32 : (float, float32_elt) kind
##V>=4.2##           | Float64 : (float, float64_elt) kind
##V>=4.2##           | Int8_signed : (int, int8_signed_elt) kind
##V>=4.2##           | Int8_unsigned : (int, int8_unsigned_elt) kind
##V>=4.2##           | Int16_signed : (int, int16_signed_elt) kind
##V>=4.2##           | Int16_unsigned : (int, int16_unsigned_elt) kind
##V>=4.2##           | Int32 : (int32, int32_elt) kind
##V>=4.2##           | Int64 : (int64, int64_elt) kind
##V>=4.2##           | Int : (int, int_elt) kind
##V>=4.2##           | Nativeint : (nativeint, nativeint_elt) kind
##V>=4.2##           | Complex32 : (Complex.t, complex32_elt) kind
##V>=4.2##           | Complex64 : (Complex.t, complex64_elt) kind
##V>=4.2##           | Char : (char, int8_unsigned_elt) kind (**)
##V>=5.2##           | Float16 : (float, float16_elt) kind
(** To each element kind is associated an OCaml type, which is
    the type of OCaml values that can be stored in the big array
    or read back from it.  This type is not necessarily the same
    as the type of the array elements proper: for instance,
    a big array whose elements are of kind [float32_elt] contains
    32-bit single precision floats, but reading or writing one of
    its elements from OCaml uses the OCaml type [float], which is
    64-bit double precision floats.

##V<4.2##    The abstract type [('a, 'b) kind] captures this association
##V<4.2##    of an OCaml type ['a] for values read or written in the big array,
##V<4.2##    and of an element kind ['b] which represents the actual contents
##V<4.2##    of the big array.  The following predefined values of type
##V<4.2##    [kind] list all possible associations of OCaml types with
##V<4.2##    element kinds:
##V>=4.2##   The GADT type [('a, 'b) kind] captures this association
##V>=4.2##   of an OCaml type ['a] for values read or written in the big array,
##V>=4.2##   and of an element kind ['b] which represents the actual contents
##V>=4.2##   of the big array. Its constructors list all possible associations
##V>=4.2##   of OCaml types with element kinds, and are re-exported below for
##V>=4.2##   backward-compatibility reasons.
##V>=4.2##
##V>=4.2##   Using a generalized algebraic datatype (GADT) here allows to write
##V>=4.2##   well-typed polymorphic functions whose return type depend on the
##V>=4.2##   argument type, such as:
##V>=4.2##{[
##V>=4.2##  let zero : type a b. (a, b) kind -> a = function
##V>=4.2##    | Float32 -> 0.0 | Complex32 -> Complex.zero
##V>=4.2##    | Float64 -> 0.0 | Complex64 -> Complex.zero
##V>=4.2##    | Int8_signed -> 0 | Int8_unsigned -> 0
##V>=4.2##    | Int16_signed -> 0 | Int16_unsigned -> 0
##V>=4.2##    | Int32 -> 0l | Int64 -> 0L
##V>=4.2##    | Int -> 0 | Nativeint -> 0n
##V>=4.2##    | Char -> '\000'
##V>=4.2##]}
*)


val float32 : (float, float32_elt) kind
(** See {!Bigarray.char}. *)

val float64 : (float, float64_elt) kind
(** See {!Bigarray.char}. *)

val complex32 : (Complex.t, complex32_elt) kind
(** See {!Bigarray.char}. *)

val complex64 : (Complex.t, complex64_elt) kind
(** See {!Bigarray.char}. *)

val int8_signed : (int, int8_signed_elt) kind
(** See {!Bigarray.char}. *)

val int8_unsigned : (int, int8_unsigned_elt) kind
(** See {!Bigarray.char}. *)

val int16_signed : (int, int16_signed_elt) kind
(** See {!Bigarray.char}. *)

val int16_unsigned : (int, int16_unsigned_elt) kind
(** See {!Bigarray.char}. *)

val int : (int, int_elt) kind
(** See {!Bigarray.char}. *)

val int32 : (int32, int32_elt) kind
(** See {!Bigarray.char}. *)

val int64 : (int64, int64_elt) kind
(** See {!Bigarray.char}. *)

val nativeint : (nativeint, nativeint_elt) kind
(** See {!Bigarray.char}. *)

val char : (char, int8_unsigned_elt) kind
(** As shown by the types of the values above,
    big arrays of kind [float32_elt] and [float64_elt] are
    accessed using the OCaml type [float].  Big arrays of complex kinds
    [complex32_elt], [complex64_elt] are accessed with the OCaml type
    {!Complex.t}.  Big arrays of
    integer kinds are accessed using the smallest OCaml integer
    type large enough to represent the array elements:
    [int] for 8- and 16-bit integer bigarrays, as well as OCaml-integer
    bigarrays; [int32] for 32-bit integer bigarrays; [int64]
    for 64-bit integer bigarrays; and [nativeint] for
    platform-native integer bigarrays.  Finally, big arrays of
    kind [int8_unsigned_elt] can also be accessed as arrays of
    characters instead of arrays of small integers, by using
    the kind value [char] instead of [int8_unsigned]. *)

val kind_size_in_bytes : ('a, 'b) kind -> int
(** [kind_size_in_bytes k] is the number of bytes used to store
   an element of type [k].

   @since 2.5.0 *)

(** {1 Array layouts} *)

type c_layout = Bigarray.c_layout
##V>=4.2## = C_layout_typ (**)
(** See {!Bigarray.fortran_layout}.*)

type fortran_layout = Bigarray.fortran_layout
##V>=4.2## = Fortran_layout_typ (**)
(** To facilitate interoperability with existing C and Fortran code,
    this library supports two different memory layouts for big arrays,
    one compatible with the C conventions,
    the other compatible with the Fortran conventions.

    In the C-style layout, array indices start at 0, and
    multi-dimensional arrays are laid out in row-major format.
    That is, for a two-dimensional array, all elements of
    row 0 are contiguous in memory, followed by all elements of
    row 1, etc.  In other terms, the array elements at [(x,y)]
    and [(x, y+1)] are adjacent in memory.

    In the Fortran-style layout, array indices start at 1, and
    multi-dimensional arrays are laid out in column-major format.
    That is, for a two-dimensional array, all elements of
    column 0 are contiguous in memory, followed by all elements of
    column 1, etc.  In other terms, the array elements at [(x,y)]
    and [(x+1, y)] are adjacent in memory.

    Each layout style is identified at the type level by the
    abstract types {!Bigarray.c_layout} and [fortran_layout] respectively. *)

type 'a layout = 'a Bigarray.layout
##V>=4.2##           = C_layout : c_layout layout
##V>=4.2##           | Fortran_layout : fortran_layout layout (**)
(** The type ['a layout] represents one of the two supported
    memory layouts: C-style if ['a] is {!Bigarray.c_layout}, Fortran-style
    if ['a] is {!Bigarray.fortran_layout}. *)


(** {2 Supported layouts}

    The abstract values [c_layout] and [fortran_layout] represent
    the two supported layouts at the level of values.
*)

val c_layout : c_layout layout
val fortran_layout : fortran_layout layout




(**Generic arrays (of arbitrarily many dimensions) *)
module Genarray :
sig
  type ('a, 'b, 'c) t = ('a, 'b, 'c) Bigarray.Genarray.t
  (** The type [Genarray.t] is the type of big arrays with variable
      numbers of dimensions.  Any number of dimensions between 1 and 16
      is supported.

      The three type parameters to [Genarray.t] identify the array element
      kind and layout, as follows:
      - the first parameter, ['a], is the OCaml type for accessing array
      elements ([float], [int], [int32], [int64], [nativeint]);
      - the second parameter, ['b], is the actual kind of array elements
      ([float32_elt], [float64_elt], [int8_signed_elt], [int8_unsigned_elt],
      etc);
      - the third parameter, ['c], identifies the array layout
      ([c_layout] or [fortran_layout]).

      For instance, [(float, float32_elt, fortran_layout) Genarray.t]
      is the type of generic big arrays containing 32-bit floats
      in Fortran layout; reads and writes in this array use the
      OCaml type [float]. *)

  external create: ('a, 'b) kind -> 'c layout -> int array -> ('a, 'b, 'c) t
    = "caml_ba_create"
  (** [Genarray.create kind layout dimensions] returns a new big array
      whose element kind is determined by the parameter [kind] (one of
      [float32], [float64], [int8_signed], etc) and whose layout is
      determined by the parameter [layout] (one of [c_layout] or
      [fortran_layout]).  The [dimensions] parameter is an array of
      integers that indicate the size of the big array in each dimension.
      The length of [dimensions] determines the number of dimensions
      of the bigarray.

      For instance, [Genarray.create int32 c_layout [|4;6;8|]]
      returns a fresh big array of 32-bit integers, in C layout,
      having three dimensions, the three dimensions being 4, 6 and 8
      respectively.

      Big arrays returned by [Genarray.create] are not initialized:
      the initial values of array elements is unspecified.

      @raise Invalid_argument if the number of dimensions
      is not in the range 1 to 16 inclusive, or if one of the dimensions
      is negative. *)

  external num_dims: ('a, 'b, 'c) t -> int = "caml_ba_num_dims"
  (** Return the number of dimensions of the given big array. *)

  val dims : ('a, 'b, 'c) t -> int array
  (** [Genarray.dims a] returns all dimensions of the big array [a],
    as an array of integers of length [Genarray.num_dims a]. *)

  external nth_dim: ('a, 'b, 'c) t -> int -> int = "caml_ba_dim"
  (** [Genarray.nth_dim a n] returns the [n]-th dimension of the
    big array [a].  The first dimension corresponds to [n = 0];
    the second dimension corresponds to [n = 1]; the last dimension,
    to [n = Genarray.num_dims a - 1].
    @raise Invalid_argument if [n] is less than 0 or greater or equal than
    [Genarray.num_dims a]. *)

  external kind: ('a, 'b, 'c) t -> ('a, 'b) kind = "caml_ba_kind"
  (** Return the kind of the given big array. *)

  external layout: ('a, 'b, 'c) t -> 'c layout = "caml_ba_layout"
  (** Return the layout of the given big array. *)

##V>=4.4##  external change_layout: ('a, 'b, 'c) t -> 'd layout -> ('a, 'b, 'd) t
##V>=4.4##      = "caml_ba_change_layout"
##V>=4.4##  (** [Genarray.change_layout a layout] returns a bigarray with the
##V>=4.4##      specified [layout], sharing the data with [a] (and hence having
##V>=4.4##      the same dimensions as [a]). No copying of elements is involved: the
##V>=4.4##      new array and the original array share the same storage space.
##V>=4.4##      The dimensions are reversed, such that [get v [| a; b |]] in
##V>=4.4##      C layout becomes [get v [| b+1; a+1 |]] in Fortran layout.
##V>=4.4##
##V>=4.4##      @since 2.5.3 and OCaml 4.04.0
##V>=4.4##  *)

  val size_in_bytes : ('a, 'b, 'c) t -> int
  (** [size_in_bytes a] is the number of elements in [a] multiplied
    by [a]'s {!kind_size_in_bytes}.

   @since 2.5.0 *)

  external get: ('a, 'b, 'c) t -> int array -> 'a = "caml_ba_get_generic"
  (** Read an element of a generic big array.
    [Genarray.get a [|i1; ...; iN|]] returns the element of [a]
    whose coordinates are [i1] in the first dimension, [i2] in
    the second dimension, ..., [iN] in the [N]-th dimension.

    If [a] has C layout, the coordinates must be greater or equal than 0
    and strictly less than the corresponding dimensions of [a].
    If [a] has Fortran layout, the coordinates must be greater or equal
    than 1 and less or equal than the corresponding dimensions of [a].
    @raise Invalid_argument if the array [a] does not have exactly [N]
    dimensions, or if the coordinates are outside the array bounds.

    If [N > 3], alternate syntax is provided: you can write
    [a.{i1, i2, ..., iN}] instead of [Genarray.get a [|i1; ...; iN|]].
    (The syntax [a.{...}] with one, two or three coordinates is
    reserved for accessing one-, two- and three-dimensional arrays
    as described below.) *)

  external set: ('a, 'b, 'c) t -> int array -> 'a -> unit
    = "caml_ba_set_generic"
  (** Assign an element of a generic big array.
    [Genarray.set a [|i1; ...; iN|] v] stores the value [v] in the
    element of [a] whose coordinates are [i1] in the first dimension,
    [i2] in the second dimension, ..., [iN] in the [N]-th dimension.

    The array [a] must have exactly [N] dimensions, and all coordinates
    must lie inside the array bounds, as described for [Genarray.get];
    @raise Invalid_argument otherwise.

    If [N > 3], alternate syntax is provided: you can write
    [a.{i1, i2, ..., iN} <- v] instead of
    [Genarray.set a [|i1; ...; iN|] v].
    (The syntax [a.{...} <- v] with one, two or three coordinates is
    reserved for updating one-, two- and three-dimensional arrays
    as described below.) *)

  external sub_left: ('a, 'b, c_layout) t -> int -> int -> ('a, 'b, c_layout) t
    = "caml_ba_sub"
  (** Extract a sub-array of the given big array by restricting the
    first (left-most) dimension.  [Genarray.sub_left a ofs len]
    returns a big array with the same number of dimensions as [a],
    and the same dimensions as [a], except the first dimension,
    which corresponds to the interval [[ofs ... ofs + len - 1]]
    of the first dimension of [a].  No copying of elements is
    involved: the sub-array and the original array share the same
    storage space.  In other terms, the element at coordinates
    [[|i1; ...; iN|]] of the sub-array is identical to the
    element at coordinates [[|i1+ofs; ...; iN|]] of the original
    array [a].

    [Genarray.sub_left] applies only to big arrays in C layout.
    @raise Invalid_argument if [ofs] and [len] do not designate
    a valid sub-array of [a], that is, if [ofs < 0], or [len < 0],
    or [ofs + len > Genarray.nth_dim a 0]. *)

  external sub_right:
    ('a, 'b, fortran_layout) t -> int -> int -> ('a, 'b, fortran_layout) t
    = "caml_ba_sub"
  (** Extract a sub-array of the given big array by restricting the
    last (right-most) dimension.  [Genarray.sub_right a ofs len]
    returns a big array with the same number of dimensions as [a],
    and the same dimensions as [a], except the last dimension,
    which corresponds to the interval [[ofs ... ofs + len - 1]]
    of the last dimension of [a].  No copying of elements is
    involved: the sub-array and the original array share the same
    storage space.  In other terms, the element at coordinates
    [[|i1; ...; iN|]] of the sub-array is identical to the
    element at coordinates [[|i1; ...; iN+ofs|]] of the original
    array [a].

    [Genarray.sub_right] applies only to big arrays in Fortran layout.
    @raise Invalid_argument if [ofs] and [len] do not designate
    a valid sub-array of [a], that is, if [ofs < 1], or [len < 0],
    or [ofs + len > Genarray.nth_dim a (Genarray.num_dims a - 1)]. *)

  external slice_left:
    ('a, 'b, c_layout) t -> int array -> ('a, 'b, c_layout) t
    = "caml_ba_slice"
  (** Extract a sub-array of lower dimension from the given big array
    by fixing one or several of the first (left-most) coordinates.
    [Genarray.slice_left a [|i1; ... ; iM|]] returns the ``slice''
    of [a] obtained by setting the first [M] coordinates to
    [i1], ..., [iM].  If [a] has [N] dimensions, the slice has
    dimension [N - M], and the element at coordinates
    [[|j1; ...; j(N-M)|]] in the slice is identical to the element
    at coordinates [[|i1; ...; iM; j1; ...; j(N-M)|]] in the original
    array [a].  No copying of elements is involved: the slice and
    the original array share the same storage space.

    [Genarray.slice_left] applies only to big arrays in C layout.
    @raise Invalid_argument if [M >= N], or if [[|i1; ... ; iM|]]
    is outside the bounds of [a]. *)

  external slice_right:
    ('a, 'b, fortran_layout) t -> int array -> ('a, 'b, fortran_layout) t
    = "caml_ba_slice"
  (** Extract a sub-array of lower dimension from the given big array
    by fixing one or several of the last (right-most) coordinates.
    [Genarray.slice_right a [|i1; ... ; iM|]] returns the ``slice''
    of [a] obtained by setting the last [M] coordinates to
    [i1], ..., [iM].  If [a] has [N] dimensions, the slice has
    dimension [N - M], and the element at coordinates
    [[|j1; ...; j(N-M)|]] in the slice is identical to the element
    at coordinates [[|j1; ...; j(N-M); i1; ...; iM|]] in the original
    array [a].  No copying of elements is involved: the slice and
    the original array share the same storage space.

    [Genarray.slice_right] applies only to big arrays in Fortran layout.
    @raise Invalid_argument if [M >= N], or if [[|i1; ... ; iM|]]
    is outside the bounds of [a]. *)

  external blit: ('a, 'b, 'c) t -> ('a, 'b, 'c) t -> unit
    = "caml_ba_blit"
  (** Copy all elements of a big array in another big array.
    [Genarray.blit src dst] copies all elements of [src] into
    [dst].  Both arrays [src] and [dst] must have the same number of
    dimensions and equal dimensions.  Copying a sub-array of [src]
    to a sub-array of [dst] can be achieved by applying [Genarray.blit]
    to sub-array or slices of [src] and [dst]. *)

  external fill: ('a, 'b, 'c) t -> 'a -> unit = "caml_ba_fill"
  (** Set all elements of a big array to a given value.
    [Genarray.fill a v] stores the value [v] in all elements of
    the big array [a].  Setting only some elements of [a] to [v]
    can be achieved by applying [Genarray.fill] to a sub-array
    or a slice of [a]. *)

  val map_file:
    Unix.file_descr -> ?pos:int64 -> ('a, 'b) kind -> 'c layout ->
    bool -> int array -> ('a, 'b, 'c) t
  (** Memory mapping of a file as a big array.
    [Genarray.map_file fd kind layout shared dims]
    returns a big array of kind [kind], layout [layout],
    and dimensions as specified in [dims].  The data contained in
    this big array are the contents of the file referred to by
    the file descriptor [fd] (as opened previously with
    [Unix.openfile], for example).  The optional [pos] parameter
    is the byte offset in the file of the data being mapped;
    it default to 0 (map from the beginning of the file).

    If [shared] is [true], all modifications performed on the array
    are reflected in the file.  This requires that [fd] be opened
    with write permissions.  If [shared] is [false], modifications
    performed on the array are done in memory only, using
    copy-on-write of the modified pages; the underlying file is not
    affected.

    [Genarray.map_file] is much more efficient than reading
    the whole file in a big array, modifying that big array,
    and writing it afterwards.

    To adjust automatically the dimensions of the big array to
    the actual size of the file, the major dimension (that is,
    the first dimension for an array with C layout, and the last
    dimension for an array with Fortran layout) can be given as
    [-1].  [Genarray.map_file] then determines the major dimension
    from the size of the file.  The file must contain an integral
    number of sub-arrays as determined by the non-major dimensions,
    @raise Failure otherwise.

    If all dimensions of the big array are given, the file size is
    matched against the size of the big array.  If the file is larger
    than the big array, only the initial portion of the file is
    mapped to the big array.  If the file is smaller than the big
    array, the file is automatically grown to the size of the big array.
    This requires write permissions on [fd]. *)

  val iter : ('a -> unit) -> ('a, 'b, 'c) t -> unit
  (** [iter f a] applies function [f] in turn to all
    the elements of [a].  *)

  val iteri : ((int, [`Read]) BatArray.Cap.t -> 'a -> unit) -> ('a, 'b, 'c) t -> unit
  (** Same as {!iter}, but the function is applied to the index of
      the element as the first argument, and the element itself as
      the second argument. *)

  val modify : ('a -> 'a) -> ('a, 'b, 'c) t -> unit
  (** [modify f a] changes each element [x] in [a] to [f x]
      in-place. *)

  val modifyi : ((int, [`Read]) BatArray.Cap.t -> 'a -> 'a) -> ('a, 'b, 'c) t -> unit
  (** Same as {!modify}, but the function is applied to the index of
      the coordinates as the first argument, and the element itself
      as the second argument. *)

  val enum : ('a, 'b, 'c) t -> 'a BatEnum.t
  (** [enum e] returns an enumeration on the elements of [e].
    The order of enumeration is unspecified.*)

  val map :
    ('a -> 'b) ->
    ('b, 'c) Bigarray.kind -> ('a, 'd, 'e) t -> ('b, 'c, 'e) t
  (** [map f kind a] applies function [f] to all the elements of [a],
      and builds a {!Bigarray.t} of kind [kind] with the results
      returned by [f]. *)

  val mapi :
    ((int, [`Read]) BatArray.Cap.t -> 'a -> 'b) ->
    ('b, 'c) Bigarray.kind -> ('a, 'd, 'e) t -> ('b, 'c, 'e) t
    (** Same as {!map}, but the function is applied to the index of the
        coordinates as the first argument, and the element itself as the
        second argument. *)


end

##V>=4.5##(** {1 Zero-dimensional arrays} *)
##V>=4.5##
##V>=4.5##(** Zero-dimensional arrays. The [Array0] structure provides operations
##V>=4.5##   similar to those of {!Bigarray.Genarray}, but specialized to the case
##V>=4.5##   of zero-dimensional arrays that only contain a single scalar value.
##V>=4.5##   Statically knowing the number of dimensions of the array allows
##V>=4.5##   faster operations, and more precise static type-checking.
##V>=4.5##   @since 2.7.0 and OCaml 4.05.0 *)
##V>=4.5##module Array0 : sig
##V>=4.5##  type ('a, 'b, 'c) t = ('a, 'b, 'c) Bigarray.Array0.t
##V>=4.5##  (** The type of zero-dimensional big arrays whose elements have
##V>=4.5##     OCaml type ['a], representation kind ['b], and memory layout ['c]. *)
##V>=4.5##
##V>=4.5##  val create: ('a, 'b) kind -> 'c layout -> ('a, 'b, 'c) t
##V>=4.5##  (** [Array0.create kind layout] returns a new bigarray of zero dimension.
##V>=4.5##     [kind] and [layout] determine the array element kind and the array
##V>=4.5##     layout as described for {!Genarray.create}. *)
##V>=4.5##
##V>=4.5##  external kind: ('a, 'b, 'c) t -> ('a, 'b) kind = "caml_ba_kind"
##V>=4.5##  (** Return the kind of the given big array. *)
##V>=4.5##
##V>=4.5##  external layout: ('a, 'b, 'c) t -> 'c layout = "caml_ba_layout"
##V>=4.5##  (** Return the layout of the given big array. *)
##V>=4.5##
##V>=4.6##  val change_layout: ('a, 'b, 'c) t -> 'd layout -> ('a, 'b, 'd) t
##V>=4.6##  (** [Array0.change_layout a layout] returns a big array with the
##V>=4.6##      specified [layout], sharing the data with [a]. No copying of elements
##V>=4.6##      is involved: the new array and the original array share the same
##V>=4.6##      storage space.
##V>=4.6##
##V>=4.6##      @since 4.06.0
##V>=4.6##  *)
##V>=4.5##
##V>=4.5##  val size_in_bytes : ('a, 'b, 'c) t -> int
##V>=4.5##  (** [size_in_bytes a] is [a]'s {!kind_size_in_bytes}. *)
##V>=4.5##
##V>=4.5##  val get: ('a, 'b, 'c) t -> 'a
##V>=4.5##  (** [Array0.get a] returns the only element in [a]. *)
##V>=4.5##
##V>=4.5##  val set: ('a, 'b, 'c) t -> 'a -> unit
##V>=4.5##  (** [Array0.set a x v] stores the value [v] in [a]. *)
##V>=4.5##
##V>=4.5##  external blit: ('a, 'b, 'c) t -> ('a, 'b, 'c) t -> unit = "caml_ba_blit"
##V>=4.5##  (** Copy the first big array to the second big array.
##V>=4.5##     See {!Genarray.blit} for more details. *)
##V>=4.5##
##V>=4.5##  external fill: ('a, 'b, 'c) t -> 'a -> unit = "caml_ba_fill"
##V>=4.5##  (** Fill the given big array with the given value.
##V>=4.5##     See {!Genarray.fill} for more details. *)
##V>=4.5##
##V>=4.5##  val of_value: ('a, 'b) kind -> 'c layout -> 'a -> ('a, 'b, 'c) t
##V>=4.5##  (** Build a zero-dimensional big array initialized from the
##V>=4.5##     given value.  *)
##V>=4.5##
##V>=4.5##end


(** {1 One-dimensional arrays} *)

(** One-dimensional arrays. The [Array1] structure provides operations
    similar to those of
    {!Bigarray.Genarray}, but specialized to the case of one-dimensional arrays.
    (The [Array2] and [Array3] structures below provide operations
    specialized for two- and three-dimensional arrays.)
    Statically knowing the number of dimensions of the array allows
    faster operations, and more precise static type-checking. *)
module Array1 : sig
  type ('a, 'b, 'c) t = ('a, 'b, 'c) Bigarray.Array1. t
  (** The type of one-dimensional big arrays whose elements have
      OCaml type ['a], representation kind ['b], and memory layout ['c]. *)

  val create: ('a, 'b) kind -> 'c layout -> int -> ('a, 'b, 'c) t
  (** [Array1.create kind layout dim] returns a new bigarray of
      one dimension, whose size is [dim].  [kind] and [layout]
      determine the array element kind and the array layout
      as described for [Genarray.create]. *)

##V<4.1##  val dim: ('a, 'b, 'c) t -> int
##V>=4.1##  external dim: ('a, 'b, 'c) t -> int = "%caml_ba_dim_1"
  (** Return the size (dimension) of the given one-dimensional
      big array. *)

  external kind: ('a, 'b, 'c) t -> ('a, 'b) kind = "caml_ba_kind"
  (** Return the kind of the given big array. *)

  external layout: ('a, 'b, 'c) t -> 'c layout = "caml_ba_layout"
  (** Return the layout of the given big array. *)

##V>=4.6##  val change_layout: ('a, 'b, 'c) t -> 'd layout -> ('a, 'b, 'd) t
##V>=4.6##  (** [Array1.change_layout a layout] returns a bigarray with the
##V>=4.6##      specified [layout], sharing the data with [a] (and hence having
##V>=4.6##      the same dimension as [a]). No copying of elements is involved: the
##V>=4.6##      new array and the original array share the same storage space.
##V>=4.6##
##V>=4.6##      @since 4.06.0
##V>=4.6##  *)

  val size_in_bytes : ('a, 'b, 'c) t -> int
  (** [size_in_bytes a] is the number of elements in [a] multiplied
    by [a]'s {!kind_size_in_bytes}.

   @since 2.5.0 *)

  external get: ('a, 'b, 'c) t -> int -> 'a = "%caml_ba_ref_1"
  (** [Array1.get a x], or alternatively [a.{x}],
      returns the element of [a] at index [x].
      [x] must be greater or equal than [0] and strictly less than
      [Array1.dim a] if [a] has C layout.  If [a] has Fortran layout,
      [x] must be greater or equal than [1] and less or equal than
      [Array1.dim a].
      @raise Invalid_argument otherwise. *)

  external set: ('a, 'b, 'c) t -> int -> 'a -> unit = "%caml_ba_set_1"
  (** [Array1.set a x v], also written [a.{x} <- v],
      stores the value [v] at index [x] in [a].
      [x] must be inside the bounds of [a] as described in
      {!Bigarray.Array1.get};
      @raise Invalid_argument otherwise. *)

  external sub: ('a, 'b, 'c) t -> int -> int -> ('a, 'b, 'c) t
    = "caml_ba_sub"
  (** Extract a sub-array of the given one-dimensional big array.
      See [Genarray.sub_left] for more details. *)

##V>=4.5##  val slice: ('a, 'b, 'c) t -> int -> ('a, 'b, 'c) Array0.t
##V>=4.5##  (** Extract a scalar (zero-dimensional slice) of the given one-dimensional
##V>=4.5##     big array.  The integer parameter is the index of the scalar to
##V>=4.5##     extract.  See {!Bigarray.Genarray.slice_left} and
##V>=4.5##     {!Bigarray.Genarray.slice_right} for more details.
##V>=4.5##     @since 2.7.0 and OCaml 4.05.0 *)

  external blit: ('a, 'b, 'c) t -> ('a, 'b, 'c) t -> unit
    = "caml_ba_blit"
  (** Copy the first big array to the second big array.
      See [Genarray.blit] for more details. *)

  external fill: ('a, 'b, 'c) t -> 'a -> unit = "caml_ba_fill"
  (** Fill the given big array with the given value.
      See [Genarray.fill] for more details. *)

  val of_array: ('a, 'b) kind -> 'c layout -> 'a array -> ('a, 'b, 'c) t
  (** Build a one-dimensional big array initialized from the
      given array.  *)

  val map_file: Unix.file_descr -> ?pos:int64 -> ('a, 'b) kind -> 'c layout ->
    bool -> int -> ('a, 'b, 'c) t
  (** Memory mapping of a file as a one-dimensional big array.
      See {!Bigarray.Genarray.map_file} for more details. *)

  val enum : ('a, 'b, 'c) t -> 'a BatEnum.t
  (** [Array1.enum e] returns an enumeration on the elements of [e].
      Contrarily to the multi-dimensional case, order of elements is
      specified: elements are in sequential order, from smaller to
      larger indices. *)

  val of_enum : ('a, 'b) kind -> 'c layout -> 'a BatEnum.t -> ('a, 'b, 'c) t
  (** [Array1.of_enum kind layout enum] returns a new one-dimensional
      big array of kind [kind] and layout [layout], with elements taken
      from the enumeration [enum] in order.

      @since 2.1
  *)

  val map :
    ('a -> 'b) ->
    ('b, 'c) Bigarray.kind -> ('a, 'd, 'e) t -> ('b, 'c, 'e) t
  (** [Array1.map f a] applies function [f] to all the elements of [a],
      and builds a {!Bigarray.Array1.t} with the results returned by [f]. *)

  val mapi :
    (int -> 'a -> 'b) ->
    ('b, 'c) Bigarray.kind -> ('a, 'd, 'e) t -> ('b, 'c, 'e) t
  (** Same as {!Bigarray.Array1.map}, but the
    function is applied to the index of the element as the first argument,
    and the element itself as the second argument. *)

  val modify : ('a -> 'a) -> ('a, 'b, 'c) t -> unit
  (** [modify f a] changes each element [x] in [a] to [f x]
      in-place. *)

  val modifyi : (int -> 'a -> 'a) -> ('a, 'b, 'c) t -> unit
  (** Same as {!Bigarray.Array1.modify}, but the function is applied
      to the index of the element as the first argument, and the
      element itself as the second argument. *)

  val to_array : ('a, 'b, 'c) t -> 'a array
  (** Build a one-dimensional array initialized from the
    given big array.  *)


  (**{1 Unsafe operations}

     In case of doubt, don't use them.*)

  external unsafe_get: ('a, 'b, 'c) t -> int -> 'a = "%caml_ba_unsafe_ref_1"
  (** Like {!Bigarray.Array1.get}, but bounds checking is not always performed.
      Use with caution and only when the program logic guarantees that
      the access is within bounds. *)

  external unsafe_set: ('a, 'b, 'c) t -> int -> 'a -> unit
    = "%caml_ba_unsafe_set_1"
    (** Like {!Bigarray.Array1.set}, but bounds checking is not always performed.
        Use with caution and only when the program logic guarantees that
        the access is within bounds. *)


end


(** {1 Two-dimensional arrays} *)

(** Two-dimensional arrays. The [Array2] structure provides operations
    similar to those of {!Bigarray.Genarray}, but specialized to the
    case of two-dimensional arrays. *)
module Array2 :
sig
  type ('a, 'b, 'c) t = ('a, 'b, 'c) Bigarray.Array2. t
  (** The type of two-dimensional big arrays whose elements have
      OCaml type ['a], representation kind ['b], and memory layout ['c]. *)

  val create: ('a, 'b) kind ->  'c layout -> int -> int -> ('a, 'b, 'c) t
  (** [Array2.create kind layout dim1 dim2] returns a new bigarray of
      two dimension, whose size is [dim1] in the first dimension
      and [dim2] in the second dimension.  [kind] and [layout]
      determine the array element kind and the array layout
      as described for {!Bigarray.Genarray.create}. *)

##V<4.1##  val dim1: ('a, 'b, 'c) t -> int
##V>=4.1##  external dim1: ('a, 'b, 'c) t -> int = "%caml_ba_dim_1"
  (** Return the first dimension of the given two-dimensional big array. *)

##V<4.1##  val dim2: ('a, 'b, 'c) t -> int
##V>=4.1##  external dim2: ('a, 'b, 'c) t -> int = "%caml_ba_dim_2"
  (** Return the second dimension of the given two-dimensional big array. *)

  external kind: ('a, 'b, 'c) t -> ('a, 'b) kind = "caml_ba_kind"
  (** Return the kind of the given big array. *)

  external layout: ('a, 'b, 'c) t -> 'c layout = "caml_ba_layout"
  (** Return the layout of the given big array. *)

##V>=4.6##  val change_layout: ('a, 'b, 'c) t -> 'd layout -> ('a, 'b, 'd) t
##V>=4.6##  (** [Array2.change_layout a layout] returns a bigarray with the
##V>=4.6##      specified [layout], sharing the data with [a] (and hence having
##V>=4.6##      the same dimensions as [a]). No copying of elements is involved: the
##V>=4.6##      new array and the original array share the same storage space.
##V>=4.6##      The dimensions are reversed, such that [get v [| a; b |]] in
##V>=4.6##      C layout becomes [get v [| b+1; a+1 |]] in Fortran layout.
##V>=4.6##
##V>=4.6##      @since 4.06.0
##V>=4.6##  *)

  val size_in_bytes : ('a, 'b, 'c) t -> int
  (** [size_in_bytes a] is the number of elements in [a] multiplied
    by [a]'s {!kind_size_in_bytes}.

   @since 2.5.0 *)

  external get: ('a, 'b, 'c) t -> int -> int -> 'a = "%caml_ba_ref_2"
  (** [Array2.get a x y], also written [a.{x,y}],
      returns the element of [a] at coordinates ([x], [y]).
      [x] and [y] must be within the bounds
      of [a], as described for {!Bigarray.Genarray.get};
      @raise Invalid_argument otherwise. *)

  external set: ('a, 'b, 'c) t -> int -> int -> 'a -> unit = "%caml_ba_set_2"
  (** [Array2.set a x y v], or alternatively [a.{x,y} <- v],
      stores the value [v] at coordinates ([x], [y]) in [a].
      [x] and [y] must be within the bounds of [a],
      as described for {!Bigarray.Genarray.set};
      @raise Invalid_argument otherwise. *)

  external sub_left: ('a, 'b, c_layout) t -> int -> int -> ('a, 'b, c_layout) t
    = "caml_ba_sub"
  (** Extract a two-dimensional sub-array of the given two-dimensional
      big array by restricting the first dimension.
      See {!Bigarray.Genarray.sub_left} for more details.
      [Array2.sub_left] applies only to arrays with C layout. *)

  external sub_right:
    ('a, 'b, fortran_layout) t -> int -> int -> ('a, 'b, fortran_layout) t
    = "caml_ba_sub"
  (** Extract a two-dimensional sub-array of the given two-dimensional
      big array by restricting the second dimension.
      See {!Bigarray.Genarray.sub_right} for more details.
      [Array2.sub_right] applies only to arrays with Fortran layout. *)

  val slice_left: ('a, 'b, c_layout) t -> int -> ('a, 'b, c_layout) Array1.t
  (** Extract a row (one-dimensional slice) of the given two-dimensional
      big array.  The integer parameter is the index of the row to
      extract.  See {!Bigarray.Genarray.slice_left} for more details.
      [Array2.slice_left] applies only to arrays with C layout. *)

  val slice_right:
    ('a, 'b, fortran_layout) t -> int -> ('a, 'b, fortran_layout) Array1.t
  (** Extract a column (one-dimensional slice) of the given
      two-dimensional big array.  The integer parameter is the
      index of the column to extract.  See {!Bigarray.Genarray.slice_right}
      for more details.  [Array2.slice_right] applies only to arrays
      with Fortran layout. *)

  external blit: ('a, 'b, 'c) t -> ('a, 'b, 'c) t -> unit
    = "caml_ba_blit"
  (** Copy the first big array to the second big array.
      See {!Bigarray.Genarray.blit} for more details. *)

  external fill: ('a, 'b, 'c) t -> 'a -> unit = "caml_ba_fill"
  (** Fill the given big array with the given value.
      See {!Bigarray.Genarray.fill} for more details. *)

  val of_array: ('a, 'b) kind -> 'c layout -> 'a array array -> ('a, 'b, 'c) t
  (** Build a two-dimensional big array initialized from the
      given array of arrays.  *)

  val map_file: Unix.file_descr -> ?pos:int64 -> ('a, 'b) kind -> 'c layout ->
    bool -> int -> int -> ('a, 'b, 'c) t
  (** Memory mapping of a file as a two-dimensional big array.
      See {!Bigarray.Genarray.map_file} for more details. *)


  val enum : ('a, 'b, 'c) t -> 'a BatEnum.t
  (** [enum e] returns an enumeration on the elements of [e].
    The order of enumeration is unspecified.*)

  val map :
    ('a -> 'b) ->
    ('b, 'c) Bigarray.kind -> ('a, 'd, 'e) t -> ('b, 'c, 'e) t
  (** [Array2.map f a] applies function [f] to all the elements of [a],
      and builds a {!Bigarray.Array2.t} with the results returned by [f]. *)

  val mapij :
    (int -> int -> 'a -> 'b) ->
    ('b, 'c) Bigarray.kind -> ('a, 'd, 'e) t -> ('b, 'c, 'e) t
  (** Same as {!Bigarray.Array2.map}, but the
      function is applied to the index of the element as the first two
      arguments, and the element itself as the third argument. *)

  val modify : ('a -> 'a) -> ('a, 'b, 'c) t -> unit
  (** [modify f a] changes each element [x] in [a] to [f x]
      in-place. *)

  val modifyij : (int -> int -> 'a -> 'a) -> ('a, 'b, 'c) t -> unit
  (** Same as {!Bigarray.Array2.modify}, but the function is applied
      to the index of the element as the first two arguments, and the
      element itself as the third argument. *)

  val to_array : ('a, 'b, 'c) t -> 'a array array
  (** Build a two-dimensional array initialized from the
      given big array.  *)

  (**{1 Unsafe operations}

     In case of doubt, don't use them.*)

  external unsafe_get: ('a, 'b, 'c) t -> int -> int -> 'a
    = "%caml_ba_unsafe_ref_2"
  (** Like {!Bigarray.Array2.get}, but bounds checking is not always
      performed. *)

  external unsafe_set: ('a, 'b, 'c) t -> int -> int -> 'a -> unit
    = "%caml_ba_unsafe_set_2"
    (** Like {!Bigarray.Array2.set}, but bounds checking is not always
        performed. *)


end

(** {1 Three-dimensional arrays} *)

(** Three-dimensional arrays. The [Array3] structure provides operations
    similar to those of {!Bigarray.Genarray}, but specialized to the case
    of three-dimensional arrays. *)
module Array3 :
sig
  type ('a, 'b, 'c) t = ('a, 'b, 'c) Bigarray.Array3. t
  (** The type of three-dimensional big arrays whose elements have
      OCaml type ['a], representation kind ['b], and memory layout ['c]. *)

  val create: ('a, 'b) kind -> 'c layout -> int -> int -> int -> ('a, 'b, 'c) t
  (** [Array3.create kind layout dim1 dim2 dim3] returns a new bigarray of
      three dimension, whose size is [dim1] in the first dimension,
      [dim2] in the second dimension, and [dim3] in the third.
      [kind] and [layout] determine the array element kind and
      the array layout as described for {!Bigarray.Genarray.create}. *)

##V<4.1##  val dim1: ('a, 'b, 'c) t -> int
##V>=4.1##  external dim1: ('a, 'b, 'c) t -> int = "%caml_ba_dim_1"
  (** Return the first dimension of the given three-dimensional big array. *)

##V<4.1##  val dim2: ('a, 'b, 'c) t -> int
##V>=4.1##  external dim2: ('a, 'b, 'c) t -> int = "%caml_ba_dim_2"
  (** Return the second dimension of the given three-dimensional big array. *)

##V<4.1##  val dim3: ('a, 'b, 'c) t -> int
##V>=4.1##  external dim3: ('a, 'b, 'c) t -> int = "%caml_ba_dim_3"
  (** Return the third dimension of the given three-dimensional big array. *)

  external kind: ('a, 'b, 'c) t -> ('a, 'b) kind = "caml_ba_kind"
  (** Return the kind of the given big array. *)

  external layout: ('a, 'b, 'c) t -> 'c layout = "caml_ba_layout"
  (** Return the layout of the given big array. *)

##V>=4.6##  val change_layout: ('a, 'b, 'c) t -> 'd layout -> ('a, 'b, 'd) t
##V>=4.6##  (** [Array3.change_layout a layout] returns a bigarray with the
##V>=4.6##      specified [layout], sharing the data with [a] (and hence having
##V>=4.6##      the same dimensions as [a]). No copying of elements is involved: the
##V>=4.6##      new array and the original array share the same storage space.
##V>=4.6##      The dimensions are reversed, such that [get v [| a; b; c |]] in
##V>=4.6##      C layout becomes [get v [| c+1; b+1; a+1 |]] in Fortran layout.
##V>=4.6##
##V>=4.6##      @since 4.06.0
##V>=4.6##  *)

  val size_in_bytes : ('a, 'b, 'c) t -> int
  (** [size_in_bytes a] is the number of elements in [a] multiplied
    by [a]'s {!kind_size_in_bytes}.

   @since 2.5.0 *)

  external get: ('a, 'b, 'c) t -> int -> int -> int -> 'a = "%caml_ba_ref_3"
  (** [Array3.get a x y z], also written [a.{x,y,z}],
      returns the element of [a] at coordinates ([x], [y], [z]).
      [x], [y] and [z] must be within the bounds of [a],
      as described for {!Bigarray.Genarray.get};
      @raise Invalid_argument otherwise. *)

  external set: ('a, 'b, 'c) t -> int -> int -> int -> 'a -> unit
    = "%caml_ba_set_3"
  (** [Array3.set a x y v], or alternatively [a.{x,y,z} <- v],
      stores the value [v] at coordinates ([x], [y], [z]) in [a].
      [x], [y] and [z] must be within the bounds of [a],
      as described for {!Bigarray.Genarray.set};
      @raise Invalid_argument otherwise. *)

  external sub_left: ('a, 'b, c_layout) t -> int -> int -> ('a, 'b, c_layout) t
    = "caml_ba_sub"
  (** Extract a three-dimensional sub-array of the given
      three-dimensional big array by restricting the first dimension.
      See {!Bigarray.Genarray.sub_left} for more details.  [Array3.sub_left]
      applies only to arrays with C layout. *)

  external sub_right:
    ('a, 'b, fortran_layout) t -> int -> int -> ('a, 'b, fortran_layout) t
    = "caml_ba_sub"
  (** Extract a three-dimensional sub-array of the given
      three-dimensional big array by restricting the second dimension.
      See {!Bigarray.Genarray.sub_right} for more details.  [Array3.sub_right]
      applies only to arrays with Fortran layout. *)

  val slice_left_1:
    ('a, 'b, c_layout) t -> int -> int -> ('a, 'b, c_layout) Array1.t
  (** Extract a one-dimensional slice of the given three-dimensional
      big array by fixing the first two coordinates.
      The integer parameters are the coordinates of the slice to
      extract.  See {!Bigarray.Genarray.slice_left} for more details.
      [Array3.slice_left_1] applies only to arrays with C layout. *)

  val slice_right_1:
    ('a, 'b, fortran_layout) t ->
    int -> int -> ('a, 'b, fortran_layout) Array1.t
  (** Extract a one-dimensional slice of the given three-dimensional
      big array by fixing the last two coordinates.
      The integer parameters are the coordinates of the slice to
      extract.  See {!Bigarray.Genarray.slice_right} for more details.
      [Array3.slice_right_1] applies only to arrays with Fortran
      layout. *)

  val slice_left_2: ('a, 'b, c_layout) t -> int -> ('a, 'b, c_layout) Array2.t
  (** Extract a  two-dimensional slice of the given three-dimensional
      big array by fixing the first coordinate.
      The integer parameter is the first coordinate of the slice to
      extract.  See {!Bigarray.Genarray.slice_left} for more details.
      [Array3.slice_left_2] applies only to arrays with C layout. *)

  val slice_right_2:
    ('a, 'b, fortran_layout) t -> int -> ('a, 'b, fortran_layout) Array2.t
  (** Extract a two-dimensional slice of the given
      three-dimensional big array by fixing the last coordinate.
      The integer parameter is the coordinate of the slice
      to extract.  See {!Bigarray.Genarray.slice_right} for more details.
      [Array3.slice_right_2] applies only to arrays with Fortran
      layout. *)

  external blit: ('a, 'b, 'c) t -> ('a, 'b, 'c) t -> unit
    = "caml_ba_blit"
  (** Copy the first big array to the second big array.
      See {!Bigarray.Genarray.blit} for more details. *)

  external fill: ('a, 'b, 'c) t -> 'a -> unit = "caml_ba_fill"
  (** Fill the given big array with the given value.
      See {!Bigarray.Genarray.fill} for more details. *)

  val of_array:
    ('a, 'b) kind -> 'c layout -> 'a array array array -> ('a, 'b, 'c) t
  (** Build a three-dimensional big array initialized from the
      given array of arrays of arrays.  *)

  val map_file: Unix.file_descr -> ?pos:int64 -> ('a, 'b) kind -> 'c layout ->
    bool -> int -> int -> int -> ('a, 'b, 'c) t
  (** Memory mapping of a file as a three-dimensional big array.
      See {!Bigarray.Genarray.map_file} for more details. *)

  val enum : ('a, 'b, 'c) t -> 'a BatEnum.t
  (** [enum e] returns an enumeration on the elements of [e].
    The order of enumeration is unspecified.*)

  val map :
    ('a -> 'b) ->
    ('b, 'c) Bigarray.kind -> ('a, 'd, 'e) t -> ('b, 'c, 'e) t
  (** [Array3.map f a] applies function [f] to all the elements of [a],
      and builds a {!Bigarray.Array3.t} with the results returned by [f]. *)

  val mapijk :
    (int -> int -> int -> 'a -> 'b) ->
    ('b, 'c) Bigarray.kind -> ('a, 'd, 'e) t -> ('b, 'c, 'e) t
  (** Same as {!Bigarray.Array3.map}, but the
      function is applied to the index of the element as the first three
      arguments, and the element itself as the fourth argument. *)

  val modify : ('a -> 'a) -> ('a, 'b, 'c) t -> unit
  (** [modify f a] changes each element [x] in [a] to [f x]
      in-place. *)

  val modifyijk : (int -> int -> int -> 'a -> 'a) -> ('a, 'b, 'c) t -> unit
  (** Same as {!Bigarray.Array3.modify}, but the function is applied
      to the index of the coordinates as the first three arguments, and the
      element itself as the fourth argument. *)

  val to_array : ('a, 'b, 'c) t -> 'a array array array
  (** Build a three-dimensional array initialized from the
      given big array.  *)

  (**{1 Unsafe operations}

     In case of doubt, don't use them.*)

  external unsafe_get: ('a, 'b, 'c) t -> int -> int -> int -> 'a
    = "%caml_ba_unsafe_ref_3"
  (** Like {!Bigarray.Array3.get}, but bounds checking is not always
      performed. *)

  external unsafe_set: ('a, 'b, 'c) t -> int -> int -> int -> 'a -> unit
    = "%caml_ba_unsafe_set_3"
    (** Like {!Bigarray.Array3.set}, but bounds checking is not always
        performed. *)


end

(** {1 Coercions between generic big arrays and fixed-dimension big arrays} *)

##V>=4.5##external genarray_of_array0 :
##V>=4.5##  ('a, 'b, 'c) Array0.t -> ('a, 'b, 'c) Genarray.t = "%identity"
##V>=4.5##(** Return the generic big array corresponding to the given zero-dimensional
##V>=4.5##   big array.
##V>=4.5##   @since 2.7.0 and OCaml 4.05.0 *)

external genarray_of_array1 :
  ('a, 'b, 'c) Array1.t -> ('a, 'b, 'c) Genarray.t = "%identity"
(** Return the generic big array corresponding to the given one-dimensional
    big array. *)

external genarray_of_array2 :
  ('a, 'b, 'c) Array2.t -> ('a, 'b, 'c) Genarray.t = "%identity"
(** Return the generic big array corresponding to the given two-dimensional
    big array. *)

external genarray_of_array3 :
  ('a, 'b, 'c) Array3.t -> ('a, 'b, 'c) Genarray.t = "%identity"
(** Return the generic big array corresponding to the given three-dimensional
    big array. *)

##V>=4.5##val array0_of_genarray : ('a, 'b, 'c) Genarray.t -> ('a, 'b, 'c) Array0.t
##V>=4.5##(** Return the zero-dimensional big array corresponding to the given
##V>=4.5##   generic big array.  Raise [Invalid_argument] if the generic big array
##V>=4.5##   does not have exactly zero dimension.
##V>=4.5##   @since 2.7.0 and OCaml 4.05.0 *)

val array1_of_genarray : ('a, 'b, 'c) Genarray.t -> ('a, 'b, 'c) Array1.t
(** Return the one-dimensional big array corresponding to the given
    generic big array.

    @raise Invalid_argument if the generic big array
    does not have exactly one dimension. *)

val array2_of_genarray : ('a, 'b, 'c) Genarray.t -> ('a, 'b, 'c) Array2.t
(** Return the two-dimensional big array corresponding to the given
    generic big array.

    @raise Invalid_argument if the generic big array
    does not have exactly two dimensions. *)

val array3_of_genarray : ('a, 'b, 'c) Genarray.t -> ('a, 'b, 'c) Array3.t
(** Return the three-dimensional big array corresponding to the given
    generic big array.

    @raise Invalid_argument if the generic big array
    does not have exactly three dimensions. *)


(** {1 Re-shaping big arrays} *)

val reshape : ('a, 'b, 'c) Genarray.t -> int array -> ('a, 'b, 'c) Genarray.t
(** [reshape b [|d1;...;dN|]] converts the big array [b] to a
    [N]-dimensional array of dimensions [d1]...[dN].  The returned
    array and the original array [b] share their data
    and have the same layout.  For instance, assuming that [b]
    is a one-dimensional array of dimension 12, [reshape b [|3;4|]]
    returns a two-dimensional array [b'] of dimensions 3 and 4.
    If [b] has C layout, the element [(x,y)] of [b'] corresponds
    to the element [x * 3 + y] of [b].  If [b] has Fortran layout,
    the element [(x,y)] of [b'] corresponds to the element
    [x + (y - 1) * 4] of [b].
    The returned big array must have exactly the same number of
    elements as the original big array [b].  That is, the product
    of the dimensions of [b] must be equal to [i1 * ... * iN].
    @raise Invalid_argument otherwise. *)

##V>=4.5##val reshape_0 : ('a, 'b, 'c) Genarray.t -> ('a, 'b, 'c) Array0.t
##V>=4.5##(** Specialized version of {!Bigarray.reshape} for reshaping to
##V>=4.5##   zero-dimensional arrays.
##V>=4.5##   @since 2.7.0 and OCaml 4.05.0 *)

val reshape_1 : ('a, 'b, 'c) Genarray.t -> int -> ('a, 'b, 'c) Array1.t
(** Specialized version of {!Bigarray.reshape} for reshaping to
    one-dimensional arrays. *)

val reshape_2 : ('a, 'b, 'c) Genarray.t -> int -> int -> ('a, 'b, 'c) Array2.t
(** Specialized version of {!Bigarray.reshape} for reshaping to
    two-dimensional arrays. *)

val reshape_3 :
  ('a, 'b, 'c) Genarray.t -> int -> int -> int -> ('a, 'b, 'c) Array3.t
    (** Specialized version of {!Bigarray.reshape} for reshaping to
        three-dimensional arrays. *)
