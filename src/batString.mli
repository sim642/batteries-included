(*
 * BatString - Additional functions for string manipulations.
 * Copyright (C) 2003 Nicolas Cannasse
 * Copyright (C) 1996 Xavier Leroy, INRIA Rocquencourt
 * Copyright (C) 2008 Edgar Friendly
 * Copyright (C) 2009 David Teller, LIFO, Universite d'Orleans
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

(** String operations.

    Given a string [s] of length [l], we call character number in [s]
    the index of a character in [s].  Indexes start at [0], and we will
    call a character number valid in [s] if it falls within the range
    [[0...l-1]]. A position is the point between two characters or at
    the beginning or end of the string.  We call a position valid
    in [s] if it falls within the range [[0...l]]. Note that character
    number [n] is between positions [n] and [n+1].

    Two parameters [start] and [len] are said to designate a valid
    substring of [s] if [len >= 0] and [start] and [start+len] are
    valid positions in [s].

    This module replaces Stdlib's
    {{:http://caml.inria.fr/pub/docs/manual-ocaml/libref/String.html}String}
    module.

    If you're going to do a lot of string slicing, BatSubstring might be
    a useful module to represent slices of strings, as it doesn't
    allocate new strings on every operation.

    @author Xavier Leroy (base library)
    @author Nicolas Cannasse
    @author David Teller
    @author Edgar Friendly
*)

val init : int -> (int -> char) -> string
(** [init l f] returns the string of length [l] with the chars
    f 0 , f 1 , f 2 ... f (l-1).

    Example: [String.init 256 char_of_int]
*)

val empty : string
(** The empty string.
    @since 3.4.0 *)

val is_empty : string -> bool
(** [is_empty s] returns [true] if [s] is the empty string, [false]
    otherwise.

    Usually a tad faster than comparing [s] with [""].

    Example (for some string [s]):
    [ if String.is_empty s then "(Empty)" else s ]
 *)

val of_bytes : Bytes.t -> string
(** Return a new string that contains the same bytes as the given byte
    sequence.
    @since 3.4.0 *)

val to_bytes : string -> Bytes.t
(** Return a new byte sequence that contains the same bytes as the given
    string.
    @since 3.4.0 *)

val cat : string -> string -> string
(** [cat s1 s2] concatenates s1 and s2 (equivalent to [s1 ^ s2]).
    @raise Invalid_argument if the result is longer then
    than {!Sys.max_string_length} bytes.
    @since 3.4.0 *)

val for_all : (char -> bool) -> string -> bool
(** [for_all p s] check if all chars in [s] satisfy the predicate [p].
    @since 3.4.0 *)

external length : string -> int = "%string_length"
(** Return the length (number of characters) of the given string. *)

external get : string -> int -> char = "%string_safe_get"
(** [String.get s n] returns character number [n] in string [s].
    You can also write [s.[n]] instead of [String.get s n].

    @raise Invalid_argument if [n] not a valid character number in [s]. *)


##V<5##external set : Bytes.t -> int -> char -> unit = "%string_safe_set"
##V<5##(** [String.set s n c] modifies string [s] in place,
##V<5##    replacing the character number [n] by [c].
##V<5##    You can also write [s.[n] <- c] instead of [String.set s n c].
##V<5##
##V<5##    @raise Invalid_argument if [n] is not a valid character number in [s]. *)

##V<5##external create : int -> Bytes.t = "caml_create_string"
##V<5##(** [String.create n] returns a fresh string of length [n].
##V<5##    The string initially contains arbitrary characters.
##V<5##
##V<5##    @raise Invalid_argument if [n < 0] or [n > ]{!Sys.max_string_length}. *)

val make : int -> char -> string
(** [String.make n c] returns a fresh string of length [n],
    filled with the character [c].

    @raise Invalid_argument if [n < 0] or [n > ]{!Sys.max_string_length}.*)

##V<5##val copy : string -> string
##V<5##(** Return a copy of the given string. *)

val sub : string -> int -> int -> string
(** [String.sub s start len] returns a fresh string of length [len],
    containing the substring of [s] that starts at position [start] and
    has length [len].

    @raise Invalid_argument if [start] and [len] do not
    designate a valid substring of [s]. *)

##V<5##val fill : Bytes.t -> int -> int -> char -> unit
##V<5##(** [String.fill s start len c] modifies the byte sequence [s] in
##V<5##    place, replacing [len] characters by [c], starting at [start].
##V<5##
##V<5##    @raise Invalid_argument if [start] and [len] do not
##V<5##    designate a valid substring of [s]. *)

val blit : string -> int -> Bytes.t -> int -> int -> unit
(** [String.blit src srcoff dst dstoff len] copies [len] characters
    from string [src], starting at character number [srcoff], to the
    byte sequence [dst], starting at character number [dstoff].

    @raise Invalid_argument if [srcoff] and [len] do not
    designate a valid substring of [src], or if [dstoff] and [len]
    do not designate a valid substring of [dst]. *)

val concat : string -> string list -> string
(** [String.concat sep sl] concatenates the list of strings [sl],
    inserting the separator string [sep] between each. *)

val iter : (char -> unit) -> string -> unit
(** [String.iter f s] applies function [f] in turn to all
    the characters of [s].  It is equivalent to
    [f s.[0]; f s.[1]; ...; f s.[String.length s - 1]; ()]. *)

val iteri : (int -> char -> unit) -> string -> unit
(** Same as {!String.iter}, but the
    function is applied to the index of the element as first argument
    (counting from 0), and the character itself as second argument.
    @since 4.00.0
*)

val map : (char -> char) -> string -> string
(** [String.map f s] applies function [f] in turn to all
    the characters of [s] and stores the results in a new string that
    is returned.
    @since 4.00.0 *)

val mapi : (int -> char -> char) -> string -> string
(** [String.mapi f s] calls [f] with each character of [s] and its
    index (in increasing index order) and stores the results in a new
    string that is returned.
    @since 4.02.0 *)

val trim : string -> string
(** Return a copy of the argument, without leading and trailing
    whitespace (according to {!BatChar.is_whitespace}).
    The characters regarded as whitespace are: [' '], ['\n'], ['\r'], ['\t'],
    ['\012'] and ['\026'].  If there is no leading nor trailing whitespace
    character in the argument, return the original string itself, not a copy.
    @since 4.00.0 *)

val escaped : string -> string
(** Return a copy of the argument, with special characters
    represented by escape sequences, following the lexical
    conventions of OCaml.  If there is no special
    character in the argument, return the original string itself,
    not a copy. Its inverse function is Scanf.unescaped. *)

val index : string -> char -> int
(** [String.index s c] returns the character number of the first
    occurrence of character [c] in string [s].

    @raise Not_found if [c] does not occur in [s]. *)

val index_opt: string -> char -> int option
(** [String.index_opt s c] returns the index of the first
    occurrence of character [c] in string [s], or
    [None] if [c] does not occur in [s].
    @since 2.7.0 *)

val rindex : string -> char -> int
(** [String.rindex s c] returns the character number of the last
    occurrence of character [c] in string [s].

    @raise Not_found if [c] does not occur in [s]. *)

val rindex_opt: string -> char -> int option
(** [String.rindex_opt s c] returns the index of the last occurrence
    of character [c] in string [s], or [None] if [c] does not occur in
    [s].
    @since 2.7.0 *)

val index_from : string -> int -> char -> int
(** [String.index_from s i c] returns the character number of the
    first occurrence of character [c] in string [s] after or at position [i].
    [String.index s c] is equivalent to [String.index_from s 0 c].

    @raise Invalid_argument if [i] is not a valid position in [s].
    @raise Not_found if [c] does not occur in [s] after position [i]. *)

val index_from_opt: string -> int -> char -> int option
(** [String.index_from_opt s i c] returns the index of the
    first occurrence of character [c] in string [s] after position [i]
    or [None] if [c] does not occur in [s] after position [i].

    [String.index_opt s c] is equivalent to [String.index_from_opt s 0 c].
    Raise [Invalid_argument] if [i] is not a valid position in [s].

    @since 2.7.0
*)

val rindex_from : string -> int -> char -> int
(** [String.rindex_from s i c] returns the character number of the
    last occurrence of character [c] in string [s] before position [i+1].
    [String.rindex s c] is equivalent to
    [String.rindex_from s (String.length s - 1) c].

    @raise Invalid_argument if [i+1] is not a valid position in [s].
    @raise Not_found if [c] does not occur in [s] before position [i+1]. *)

val rindex_from_opt: string -> int -> char -> int option
(** [String.rindex_from_opt s i c] returns the index of the
   last occurrence of character [c] in string [s] before position [i+1]
   or [None] if [c] does not occur in [s] before position [i+1].

   [String.rindex_opt s c] is equivalent to
   [String.rindex_from_opt s (String.length s - 1) c].

   Raise [Invalid_argument] if [i+1] is not a valid position in [s].

    @since 2.7.0
*)

val index_after_n :  char -> int -> string -> int
(** [index_after_n chr n str] returns the index of the character that
    comes immediately after the [n]-th occurrence of [chr] in [str].

    - {b Occurrences are numbered from 1}: [n] = 1 returns the index of
      the character located immediately after the first occurrence of
      [chr].
    - [n] = 0 always returns [0].
    - If the [n]-th occurrence of [chr] is the last character of
      [str], returns the length of [str].

    @raise Invalid_argument if [n < 0].
    @raise Not_found if there are strictly less than [n] occurrences of [chr]
    in [str].

    @since 2.9.0
*)

val contains : string -> char -> bool
(** [String.contains s c] tests if character [c]
    appears in the string [s]. *)

val contains_from : string -> int -> char -> bool
(** [String.contains_from s start c] tests if character [c]
    appears in [s] after position [start].
    [String.contains s c] is equivalent to
    [String.contains_from s 0 c].

    @raise Invalid_argument if [start] is not a valid position in [s]. *)

val rcontains_from : string -> int -> char -> bool
(** [String.rcontains_from s stop c] tests if character [c]
    appears in [s] before position [stop+1].

    @raise Invalid_argument if [stop < 0] or [stop+1] is not a valid
    position in [s]. *)

##V<5##val uppercase : string -> string
##V<5##(** Return a copy of the argument, with all lowercase letters
##V<5##    translated to uppercase, including accented letters of the ISO
##V<5##    Latin-1 (8859-1) character set. *)

##V<5##val lowercase : string -> string
##V<5##(** Return a copy of the argument, with all uppercase letters
##V<5##    translated to lowercase, including accented letters of the ISO
##V<5##    Latin-1 (8859-1) character set. *)

##V<5##val capitalize : string -> string
##V<5##(** Return a copy of the argument, with the first character set to uppercase. *)
##V<5##
##V<5##val uncapitalize : string -> string
##V<5##(** Return a copy of the argument, with the first character set to lowercase. *)

val uppercase_ascii : string -> string
(** Return a copy of the argument, with all lowercase letters
   translated to uppercase, using the US-ASCII character set.
   @since 2.5.0 *)

val lowercase_ascii : string -> string
(** Return a copy of the argument, with all uppercase letters
   translated to lowercase, using the US-ASCII character set.
   @since 2.5.0 *)

val capitalize_ascii : string -> string
(** Return a copy of the argument, with the first character set to uppercase,
   using the US-ASCII character set.
   @since 2.5.0 *)

val uncapitalize_ascii : string -> string
(** Return a copy of the argument, with the first character set to lowercase,
   using the US-ASCII character set.
   @since 2.5.0 *)

type t = string
(** An alias for the type of strings. *)

val compare: t -> t -> int
(** The comparison function for strings, with the same specification as
    {!Pervasives.compare}.  Along with the type [t], this function [compare]
    allows the module [String] to be passed as argument to the functors
    {!Set.Make} and {!Map.Make}. *)

(** {1 Conversions} *)

val enum : string -> char BatEnum.t
(** Returns an enumeration of the characters of a string.
    The behaviour is unspecified if the string is mutated
    while it is enumerated.

    Examples:
      ["foo" |> String.enum |> List.of_enum = ['f'; 'o'; 'o']]
      [String.enum "a b c" // ((<>) ' ') |> String.of_enum = "abc"]
*)

val of_enum : char BatEnum.t -> string
(** Creates a string from a character enumeration.
    Example: [['f'; 'o'; 'o'] |> List.enum |> String.of_enum = "foo"]
*)

val backwards : string -> char BatEnum.t
(** Returns an enumeration of the characters of a string, from last to first.

    Examples:
    [ "foo" |> String.backwards |> String.of_enum = "oof" ]
    [ let rev s = String.backwards s |> String.of_enum ]
*)

val of_backwards : char BatEnum.t -> string
(** Build a string from an enumeration, starting with last character, ending with first.

    Examples:
    [ "foo" |> String.enum |> String.of_backwards = "oof" ]
    [ "foo" |> String.backwards |> String.of_backwards = "foo" ]
    [ let rev s = String.enum s |> String.of_backwards ]
*)


val of_list : char list -> string
(** Converts a list of characters to a string.

    Example: [ ['c'; 'h'; 'a'; 'r'; 's'] |> String.of_list = "chars" ]
*)

val to_list : string -> char list
(** Converts a string to the list of its characters.

    Example: [ String.to_list "string" |> List.interleave ';' |> String.of_list = "s;t;r;i;n;g" ]
*)

val of_int : int -> string
(** Returns the string representation of an int.

    Example: [ String.of_int 56 = "56" && String.of_int (-1) = "-1" ]
*)

val of_float : float -> string
(** Returns the string representation of an float.

    Example: [ String.of_float 1.246 = "1.246" ]
*)

val of_char : char -> string
(** Returns a string containing one given character.

    Example: [ String.of_char 's' = "s" ]
*)

val to_int : string -> int
(** Returns the integer represented by the given string.
    This follows OCaml's int literal rules, so "0x"
    prefixes hexadecimal integers, "0o" for octal and "0b" for
    binary.  Underscores within the number are allowed for
    readability but ignored.

    Examples: [ String.to_int "8_480" = String.to_int "0x21_20" ]
    [ try ignore(String.to_int "2,3"); false with Failure _ -> true ]

    @raise Failure if the string does not represent an integer.
*)

val to_float : string -> float
(** Returns the float represented by the given string.
    Decimal points aren't required in the given string, as they are
    for float literals in OCaml, but otherwise the rules for float
    literals apply.

    Examples: [String.to_float "12.34e-1" = String.to_float "1.234"]
    [String.to_float "1" = 1.]
    [try ignore(String.to_float ""); false with Failure _ -> true]

    @raise Failure if the string does not represent a float.
*)

(** {1 String traversals} *)

val map : (char -> char) -> string -> string
(** [map f s] returns a string where all characters [c] in [s] have been
    replaced by [f c].

    Example: [String.map Char.uppercase "Five" = "FIVE"]
 **)

val fold_left : ('a -> char -> 'a) -> 'a -> string -> 'a
(** [fold_left f a s] is
    [f (... (f (f a s.[0]) s.[1]) ...) s.[n-1]]

    Examples: [String.fold_left (fun li c -> c::li) [] "foo" = ['o';'o';'f']]
    [String.fold_left max 'a' "apples" = 's']
*)

val fold_lefti : ('a -> int -> char -> 'a) -> 'a -> string -> 'a
(** As [fold_left], but with the index of the element as additional argument

    @since 2.3.0
*)

val fold_right : (char -> 'a -> 'a) -> string -> 'a -> 'a
(** [fold_right f s b] is
    [f s.[0] (f s.[1] (... (f s.[n-1] b) ...))]

    Examples: [String.fold_right List.cons "foo" [] = ['f';'o';'o']]
    [String.fold_right (fun c a -> if c = ' ' then a+1 else a) "a b c" 0 = 2]
*)

val fold_righti : (int -> char -> 'a -> 'a) -> string -> 'a -> 'a
(** As [fold_right], but with the index of the element as additional argument

    @since 2.3.0
*)

val filter : (char -> bool) -> string -> string
(** [filter f s] returns a copy of string [s] in which only
    characters [c] such that [f c = true] remain.

    Example: [ String.filter ((<>) ' ') "a b c" = "abc" ]
*)

val filter_map : (char -> char option) -> string -> string
(** [filter_map f s] calls [(f a0) (f a1).... (f an)] where [a0..an] are
    the characters of [s]. It returns the string of characters [ci] such as
    [f ai = Some ci] (when [f] returns [None], the corresponding element of
    [s] is discarded).

    Example: [ String.filter_map (function 'a'..'z' as c -> Some (Char.uppercase c) | _ -> None) "a b c" = "ABC" ]
*)


val iteri : (int -> char -> unit) -> string -> unit
(** [String.iteri f s] is equivalent to
    [f 0 s.[0]; f 1 s.[1]; ...; f len s.[len]] where [len] is length of string [s].
    Example:
    {[ let letter_positions word =
      let positions = Array.make 256 [] in
      let count_letter pos c =
        positions.(int_of_char c) <- pos :: positions.(int_of_char c) in
      String.iteri count_letter word;
      Array.mapi (fun c pos -> (char_of_int c, List.rev pos)) positions
      |> Array.to_list
      |> List.filter (fun (c,pos) -> pos <> [])
      in
      letter_positions "hello" = ['e',[1]; 'h',[0]; 'l',[2;3]; 'o',[4] ]
    ]}
*)

(** {1 Finding}*)



val find : string -> string -> int
(** [find s x] returns the starting index of the first occurrence of
    string [x] within string [s].

    {b Note} This implementation is optimized for short strings.

    @raise Not_found if [x] is not a substring of [s].

    Example: [String.find "foobarbaz" "bar" = 3]
*)

val find_from: string -> int -> string -> int
(** [find_from s pos x] behaves as [find s x] but starts searching
    at position [pos]. [find s x] is equivalent to [find_from s 0 x].

    @raise Not_found if not substring is found
    @raise Invalid_argument if [pos] is not a valid position in the string.

    Example: [String.find_from "foobarbaz" 4 "ba" = 6]
*)

val rfind : string -> string -> int
(** [rfind s x] returns the starting index of the last occurrence
    of string [x] within string [s].

    {b Note} This implementation is optimized for short strings.

    @raise Not_found if [x] is not a substring of [s].

    Example: [String.rfind "foobarbaz" "ba" = 6]
*)

val rfind_from: string -> int -> string -> int
(** [rfind_from s pos x] behaves as [rfind s x] but starts searching
    from the right at position [pos + 1]. [rfind s x] is equivalent to
    [rfind_from s (String.length s - 1) x].

    {b Beware}, it search between the {e beginning} of the string to
    the position [pos + 1], {e not} between [pos + 1] and the end.

    @raise Not_found if not substring is found
    @raise Invalid_argument if [pos] is not a valid position in the string.

    Example: [String.rfind_from "foobarbaz" 6 "ba" = 6]
*)

val find_all : string -> string -> int BatEnum.t
(** [find_all s x] enumerates positions of [s] at which [x] occurs.
    Example: [find_all "aabaabaa" "aba" |> List.of_enum] will return
    the list [[1; 4]].
    @since 2.2.0 *)

val count_string : string -> string -> int
(** [count_string s x] count how many times [x] is found in [s].
    @since 2.9.0 *)

val ends_with : string -> string -> bool
(** [ends_with s x] returns [true] if the string [s] is ending with [x], [false] otherwise.

    Example: [String.ends_with "foobarbaz" "rbaz" = true]
*)

val starts_with : string -> string -> bool
(** [starts_with s x] returns [true] if [s] is starting with [x], [false] otherwise.

    Example: [String.starts_with "foobarbaz" "fooz" = false]
*)

val starts_with_stdlib : prefix:string -> string -> bool
(** Equivalent to [starts_with] but the prefix is a labelled parameter.
    @since 3.4.0 *)

val ends_with_stdlib : suffix:string -> string -> bool
(** Equivalent to [ends_with] but the suffix is a labelled parameter.
    @since 3.4.0 *)

val exists : string -> string -> bool
(** [exists str sub] returns true if [sub] is a substring of [str] or
    false otherwise.

    Example: [String.exists "foobarbaz" "obar" = true]
*)

val exists_stdlib : (char -> bool) -> string -> bool
(** [exists_stdlib p str] check if at least one char of [str] satisfies
    the predicate [p].
    @since 3.4.0 *)

val count_char : string -> char -> int
(** [count_char str c] returns the number of times [c] is used in [str].
 *)


(** {1 Transformations}*)

val lchop : ?n:int -> string -> string
(** Returns the same string but without the first [n] characters.
    By default [n] is 1.
    @raise Invalid_argument If [n] is strictly less than zero.
    If the string has [n] or less characters, returns the empty string.

      Example:
      [String.lchop "Weeble" = "eeble"]
      [String.lchop ~n:3 "Weeble" = "ble"]
      [String.lchop ~n:1000 "Weeble" = ""]
*)

val rchop : ?n:int -> string -> string
(** Returns the same string but without the last [n] characters.
    By default [n] is 1.
    @raise Invalid_argument If [n] is strictly less than zero.
    If the string has [n] or less characters , returns the empty string.

      Example:
      [String.rchop "Weeble" = "Weebl"]
      [String.rchop ~n:3 "Weeble" = "Wee"]
      [String.rchop ~n:1000 "Weeble" = ""]
*)

val chop : ?l:int -> ?r:int -> string -> string
(** Returns the same string but with the first [l] characters
    on the left and the first [r] characters on the right removed.
    By default, [l] and [r] are both 1.

    [chop ~l ~r s] is equivalent to [lchop ~n:l (rchop ~n:r s)].

    @raise Invalid_argument if either [l] or [r] is less than zero.

    Examples:
    [String.chop "\"Weeble\"" = "Weeble"]
    [String.chop ~l:2 ~r:3 "01234567" = "234"]
*)

val quote : string -> string
(** Add quotes around a string and escape any quote or escape
    appearing in that string.  This function is used typically when
    you need to generate source code from a string.

    Examples:
    [String.quote "foo" = "\"foo\""]
    [String.quote "\"foo\"" = "\"\\\"foo\\\"\""]
    [String.quote "\n" = "\"\\n\""]
    etc.

    More precisely, the returned string conforms to the OCaml syntax:
    if printed, it outputs a representation of the input string as an
    OCaml string litteral.
*)

val left : string -> int -> string
(**[left r len] returns the string containing the [len] first
   characters of [r]. If [r] contains less than [len] characters, it
   returns [r].

   Examples:
   [String.left "Weeble" 4 = "Weeb"]
   [String.left "Weeble" 0 = ""]
   [String.left "Weeble" 10 = "Weeble"]
*)

val right : string -> int -> string
(**[right r len] returns the string containing the [len] last characters of [r].
   If [r] contains less than [len] characters, it returns [r].

   Example: [String.right "Weeble" 4 = "eble"]
*)

val head : string -> int -> string
(**as {!left}*)

val tail : string -> int -> string
(**[tail r pos] returns the string containing all but the [pos] first characters of [r]

   Example: [String.tail "Weeble" 4 = "le"]
*)

val strip : ?chars:string -> string -> string
(** Returns the string without the chars if they are at the beginning or
    at the end of the string. By default chars are " \t\r\n".

    Examples:
    [String.strip " foo " = "foo"]
    [String.strip ~chars:" ,()" " boo() bar()" = "boo() bar"]
*)

val replace_chars : (char -> string) -> string -> string
(** [replace_chars f s] returns a string where all chars [c] of [s] have been
    replaced by the string returned by [f c].

    Example: [String.replace_chars (function ' ' -> "(space)" | c -> String.of_char c) "foo bar" = "foo(space)bar"]
*)

val replace : str:string -> sub:string -> by:string -> bool * string
(** [replace ~str ~sub ~by] returns a tuple consisting of a boolean
    and a string where the first occurrence of the string [sub]
    within [str] has been replaced by the string [by]. The boolean
    is true if a substitution has taken place.

    Example: [String.replace "foobarbaz" "bar" "rab" = (true, "foorabbaz")]
*)

val nreplace : str:string -> sub:string -> by:string -> string
(** [nreplace ~str ~sub ~by] returns a string obtained by iteratively
    replacing each occurrence of [sub] by [by] in [str], from right to left.
    It returns a copy of [str] if [sub] has no occurrence in [str].

    Example: [nreplace ~str:"bar foo aaa bar" ~sub:"aa" ~by:"foo" = "bar foo afoo bar"]
*)

val repeat: string -> int -> string
(** [repeat s n] returns [s ^ s ^ ... ^ s]

    Example: [String.repeat "foo" 4 = "foofoofoofoo"]
*)

val rev : string -> string
(** [rev s] returns the reverse of string [s]

    @since 2.1
*)

(** {1 In-Place Transformations}*)

val rev_in_place : Bytes.t -> unit
(** [rev_in_place s] mutates the byte sequence [s], so that its new value is
    the mirror of its old one: for instance if s contained ["Example!"], after
    the mutation it will contain ["!elpmaxE"]. *)

val in_place_mirror : Bytes.t -> unit
(** @deprecated Use {!String.rev_in_place} instead *)

(** {1 Splitting around}*)

val split_on_char: char -> string -> string list
(** [String.split_on_char sep s] returns the list of all (possibly empty)
    substrings of [s] that are delimited by the [sep] character.

    The function's output is specified by the following invariants:

    - The list is not empty.
    - Concatenating its elements using [sep] as a separator returns a
      string equal to the input ([String.concat (String.make 1 sep)
      (String.split_on_char sep s) = s]).
    - No string in the result contains the [sep] character.

    Note: prior to 2.11.0 [split_on_char _ ""] used to return an empty list.
    @since 2.5.3
*)

val split : string -> by:string -> string * string
(** [split s sep] splits the string [s] between the first
    occurrence of [sep], and returns the two parts before
    and after the occurrence (excluded).

    @raise Not_found if the separator is not found.

    Examples:
    [String.split "abcabcabc" "bc" = ("a","abcabc")]
    [String.split "abcabcabc" "" = ("","abcabcabc")]
*)

val rsplit : string -> by:string -> string * string
(** [rsplit s sep] splits the string [s] between the last occurrence
    of [sep], and returns the two parts before and after the
    occurrence (excluded).

    @raise Not_found if the separator is not found.

    Example: [String.rsplit "abcabcabc" "bc" = ("abcabca","")]
*)

val nsplit : string -> by:string -> string list
##V>=4.2##  [@@ocaml.deprecated "Use split_on_string instead."]
(** [nsplit s sep] splits the string [s] into a list of strings
    which are separated by [sep] (excluded).
    [nsplit "" _] returns a single empty string.
    Note: prior to 2.11.0 [nsplit "" _] used to return an empty list.

    Example: [String.nsplit "abcabcabc" "bc" = ["a"; "a"; "a"; ""]]

    @deprecated use {!split_on_string}
*)

val split_on_string : by:string -> string -> string list
(** [split_on_string sep s] splits the string [s] into a list of strings
    which are separated by [sep] (excluded).
    [split_on_string _ ""] returns a single empty string.
    Note: [split_on_string sep s] is identical to [nsplit s sep] but for empty strings.

    Example: [String.split_on_string "bc" "abcabcabc" = ["a"; "a"; "a"; ""]]

    @since 2.11.0
*)

val cut_on_char : char -> int -> string -> string
(**
   Similar to Unix [cut]. [cut_on_char chr n str] returns the substring of
   [str] located strictly between the [n]-th occurrence of [chr] and
   the [n+1]-th one.

   - {b Occurrences of [chr] are numbered from 1}.
   - If [n = 0], returns the substring from the beginning of
     [str] to the first occurrence of [chr].
   - If there are exactly [n] occurrences of [chr] in [str], returns the
     substring between the last occurrence of [chr] and the end of [str].
   - These behaviours cumulate: if [n] equals [0] and [chr] is
     absent from [str], returns the full string [str].

   {b Remark:} [cut_on_char] can return the empty string. Examples of this
   behaviour are [cut_on_char ',' 1 "foo,,bar"] and [cut_on_char ',' 0 ",foo"].

   @raise Not_found if there are strictly less than [n] occurrences of [chr] in str.
   @raise Invalid_argument if [n < 0].

   @since 2.9.0
*)

val join : string -> string list -> string
(** Same as {!concat} *)

val slice : ?first:int -> ?last:int -> string -> string
(** [slice ?first ?last s] returns a "slice" of the string
    which corresponds to the characters [s.[first]],
    [s.[first+1]], ..., [s[last-1]]. Note that the character at
    index [last] is {b not} included! If [first] is omitted it
    defaults to the start of the string, i.e. index 0, and if
    [last] is omitted is defaults to point just past the end of
    [s], i.e. [length s].  Thus, [slice s] is equivalent to
    [copy s].

    Negative indexes are interpreted as counting from the end of
    the string. For example, [slice ~last:(-2) s] will return the
    string [s], but without the last two characters.

    This function {b never} raises any exceptions. If the
    indexes are out of bounds they are automatically clipped.

    Example: [String.slice ~first:1 ~last:(-3) " foo bar baz" = "foo bar "]
*)

val splice: string -> int -> int -> string -> string
(** [String.splice s off len rep] cuts out the section of [s]
    indicated by [off] and [len] and replaces it by [rep]

    Negative indexes are interpreted as counting from the end
    of the string. If [off+len] is greater than [length s],
    the end of the string is used, regardless of the value of
    [len].

    If [len] is zero or negative, [rep] is inserted at position
    [off] without replacing any of [s].

    Example: [String.splice "foo bar baz" 3 5 "XXX" = "fooXXXbaz"]
*)

val explode : string -> char list
(** [explode s] returns the list of characters in the string [s].

    Example: [String.explode "foo" = ['f'; 'o'; 'o']]
*)

val implode : char list -> string
(** [implode cs] returns a string resulting from concatenating
    the characters in the list [cs].

    Example: [String.implode ['b'; 'a'; 'r'] = "bar"]
*)

##V>=4.07##(** {1 Iterators} *)

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

(** {1 Binary decoding of integers} *)

(** The functions in this section binary decode integers from strings.

    All following functions raise [Invalid_argument] if the characters
    needed at index [i] to decode the integer are not available.

    Little-endian (resp. big-endian) encoding means that least
    (resp. most) significant bytes are stored first.  Big-endian is
    also known as network byte order.  Native-endian encoding is
    either little-endian or big-endian depending on {!Sys.big_endian}.

    32-bit and 64-bit integers are represented by the [int32] and
    [int64] types, which can be interpreted either as signed or
    unsigned numbers.

    8-bit and 16-bit integers are represented by the [int] type,
    which has more bits than the binary encoding.  These extra bits
    are sign-extended (or zero-extended) for functions which decode 8-bit
    or 16-bit integers and represented them with [int] values.
*)

val get_uint8 : string -> int -> int
(** [get_uint8 b i] is [b]'s unsigned 8-bit integer starting at character
    index [i].
    @since 3.4.0 *)

##V>=4.08##val get_int8 : string -> int -> int
##V>=4.08##(** [get_int8 b i] is [b]'s signed 8-bit integer starting at character
##V>=4.08##    index [i].
##V>=4.08##    @since 3.4.0 and OCaml 4.08 *)

##V>=4.08##val get_uint16_ne : string -> int -> int
##V>=4.08##(** [get_uint16_ne b i] is [b]'s native-endian unsigned 16-bit integer
##V>=4.08##    starting at character index [i].
##V>=4.08##    @since 3.4.0 and OCaml 4.08 *)

##V>=4.08##val get_uint16_be : string -> int -> int
##V>=4.08##(** [get_uint16_be b i] is [b]'s big-endian unsigned 16-bit integer
##V>=4.08##    starting at character index [i].
##V>=4.08##    @since 3.4.0 and OCaml 4.08 *)

##V>=4.08##val get_uint16_le : string -> int -> int
##V>=4.08##(** [get_uint16_le b i] is [b]'s little-endian unsigned 16-bit integer
##V>=4.08##    starting at character index [i].
##V>=4.08##    @since 3.4.0 and OCaml 4.08 *)

##V>=4.08##val get_int16_ne : string -> int -> int
##V>=4.08##(** [get_int16_ne b i] is [b]'s native-endian signed 16-bit integer
##V>=4.08##    starting at character index [i].
##V>=4.08##    @since 3.4.0 and OCaml 4.08 *)

##V>=4.08##val get_int16_be : string -> int -> int
##V>=4.08##(** [get_int16_be b i] is [b]'s big-endian signed 16-bit integer
##V>=4.08##    starting at character index [i].
##V>=4.08##    @since 3.4.0 and OCaml 4.08 *)

##V>=4.08##val get_int16_le : string -> int -> int
##V>=4.08##(** [get_int16_le b i] is [b]'s little-endian signed 16-bit integer
##V>=4.08##    starting at character index [i].
##V>=4.08##    @since 3.4.0 and OCaml 4.08 *)

##V>=4.08##val get_int32_ne : string -> int -> int32
##V>=4.08##(** [get_int32_ne b i] is [b]'s native-endian 32-bit integer
##V>=4.08##    starting at character index [i].
##V>=4.08##    @since 3.4.0 and OCaml 4.08 *)

##V>=5##val hash : t -> int
##V>=5##(** An unseeded hash function for strings, with the same output value as
##V>=5##    {!Hashtbl.hash}. This function allows this module to be passed as argument
##V>=5##    to the functor {!Hashtbl.Make}.
##V>=5##
##V>=5##    @since 3.6.0 and OCaml 5.0.0 *)

##V>=5##val seeded_hash : int -> t -> int
##V>=5##(** A seeded hash function for strings, with the same output value as
##V>=5##    {!Hashtbl.seeded_hash}. This function allows this module to be passed as
##V>=5##    argument to the functor {!Hashtbl.MakeSeeded}.
##V>=5##
##V>=5##    @since 3.6.0 and OCaml 5.0.0 *)

##V>=4.08##val get_int32_be : string -> int -> int32
##V>=4.08##(** [get_int32_be b i] is [b]'s big-endian 32-bit integer
##V>=4.08##    starting at character index [i].
##V>=4.08##    @since 3.4.0 and OCaml 4.08 *)

##V>=4.08##val get_int32_le : string -> int -> int32
##V>=4.08##(** [get_int32_le b i] is [b]'s little-endian 32-bit integer
##V>=4.08##    starting at character index [i].
##V>=4.08##    @since 3.4.0 and OCaml 4.08 *)

##V>=4.08##val get_int64_ne : string -> int -> int64
##V>=4.08##(** [get_int64_ne b i] is [b]'s native-endian 64-bit integer
##V>=4.08##    starting at character index [i].
##V>=4.08##    @since 3.4.0 and OCaml 4.08 *)

##V>=4.08##val get_int64_be : string -> int -> int64
##V>=4.08##(** [get_int64_be b i] is [b]'s big-endian 64-bit integer
##V>=4.08##    starting at character index [i].
##V>=4.08##    @since 3.4.0 and OCaml 4.08 *)

##V>=4.08##val get_int64_le : string -> int -> int64
##V>=4.08##(** [get_int64_le b i] is [b]'s little-endian 64-bit integer
##V>=4.08##    starting at character index [i].
##V>=4.08##    @since 3.4.0 and OCaml 4.08 *)

##V>=4.14##(** {1:utf UTF decoding and validations}
##V>=4.14##
##V>=4.14##    @since 4.14 *)

##V>=4.14##(** {2:utf_8 UTF-8} *)
##V>=4.14##
##V>=4.14##val get_utf_8_uchar : t -> int -> Uchar.utf_decode
##V>=4.14##(** [get_utf_8_uchar b i] decodes an UTF-8 character at index [i] in
##V>=4.14##    [b]. *)

##V>=4.14##val is_valid_utf_8 : t -> bool
##V>=4.14##(** [is_valid_utf_8 b] is [true] if and only if [b] contains valid
##V>=4.14##    UTF-8 data. *)

##V>=4.14##(** {2:utf_16be UTF-16BE} *)
##V>=4.14##
##V>=4.14##val get_utf_16be_uchar : t -> int -> Uchar.utf_decode
##V>=4.14##(** [get_utf_16be_uchar b i] decodes an UTF-16BE character at index
##V>=4.14##    [i] in [b]. *)

##V>=4.14##val is_valid_utf_16be : t -> bool
##V>=4.14##(** [is_valid_utf_16be b] is [true] if and only if [b] contains valid
##V>=4.14##    UTF-16BE data. *)

##V>=4.14##(** {2:utf_16le UTF-16LE} *)
##V>=4.14##
##V>=4.14##val get_utf_16le_uchar : t -> int -> Uchar.utf_decode
##V>=4.14##(** [get_utf_16le_uchar b i] decodes an UTF-16LE character at index
##V>=4.14##    [i] in [b]. *)

##V>=4.14##val is_valid_utf_16le : t -> bool
##V>=4.14##(** [is_valid_utf_16le b] is [true] if and only if [b] contains valid
##V>=4.14##    UTF-16LE data. *)

(** {1 Comparisons}*)

val equal : t -> t -> bool
(** String equality *)

val ord : t -> t -> BatOrd.order
(** Ordering function for strings, see {!BatOrd} *)

val compare: t -> t -> int
(** The comparison function for strings, with the same specification as
    {!Pervasives.compare}.  Along with the type [t], this function [compare]
    allows the module [String] to be passed as argument to the functors
    {!Set.Make} and {!Map.Make}.

    Example: [String.compare "FOO" "bar" = -1] i.e. "FOO" < "bar"
*)

val icompare: t -> t -> int
(** Compare two strings, case-insensitive.

    Example: [String.icompare "FOO" "bar" = 1] i.e. "foo" > "bar"
*)

module IString : BatInterfaces.OrderedType with type t = t
(** uses icompare as ordering function

    Example: [module Nameset = Set.Make(String.IString)]
*)


val numeric_compare: t -> t -> int
(** Compare two strings, sorting "abc32def" before "abc210abc".

    Algorithm: splits both strings into lists of (strings of digits) or
    (strings of non digits) ([["abc"; "32"; "def"]] and [["abc"; "210"; "abc"]])
    Then both lists are compared lexicographically by comparing elements
    numerically when both are numbers or lexicographically in other cases.

    Example: [String.numeric_compare "xx32" "xx210" < 0]
*)

module NumString : BatInterfaces.OrderedType with type t = t
(** uses numeric_compare as its ordering function

    Example: [module FilenameSet = Set.Make(String.NumString)]
*)

val edit_distance : t -> t -> int
(** Edition distance (also known as "Levenshtein distance").
    See {{:http://en.wikipedia.org/wiki/Levenshtein_distance} wikipedia}
    @since 2.2.0
*)

(** {1 Boilerplate code}*)

(** {2 Printing}*)

val print: 'a BatInnerIO.output -> string -> unit
(**Print a string.

   Example: [String.print stdout "foo\n"]
*)

val println: 'a BatInnerIO.output -> string -> unit
(**Print a string, end the line.

   Example: [String.println stdout "foo"]
*)

val print_quoted: 'a BatInnerIO.output -> string -> unit
(**Print a string, with quotes as added by the [quote] function.

   [String.print_quoted stdout "foo"] prints ["foo"] (with the quotes).

   [String.print_quoted stdout "\"bar\""] prints ["\"bar\""] (with the quotes).

   [String.print_quoted stdout "\n"] prints ["\n"] (not the escaped
   character, but ['\'] then ['n']).
*)

(** Exceptionless counterparts for error-raising operations *)
module Exceptionless :
sig
  val to_int : string -> int option
  (** Returns the integer represented by the given string or
      [None] if the string does not represent an integer.*)

  val to_float : string -> float option
  (** Returns the float represented by the given string or
      [None] if the string does not represent a float. *)

  val index : string -> char -> int option
  (** [index s c] returns [Some p], the position of the leftmost
      occurrence of character [c] in string [s] or
      [None] if [c] does not occur in [s]. *)

  val rindex : string -> char -> int option
  (** [rindex s c] returns [Some p], the position of the rightmost
      occurrence of character [c] in string [s] or
      [None] if [c] does not occur in [s]. *)

  val index_from : string -> int -> char -> int option
  (** Same as {!String.Exceptionless.index}, but start
      searching at the character position given as second argument.
      [index s c] is equivalent to [index_from s 0 c].*)

  val rindex_from : string -> int -> char -> int option
  (** Same as {!String.Exceptionless.rindex}, but start
      searching at the character position given as second argument.
      [rindex s c] is equivalent to
      [rindex_from s (String.length s - 1) c]. *)

  val find : string -> string -> int option
  (** [find s x] returns [Some i], the starting index of the first
      occurrence of string [x] within string [s], or [None] if [x]
      is not a substring of [s].

      {b Note} This implementation is optimized for short strings. *)

  val find_from : string -> int -> string -> int option
  (** [find_from s ofs x] behaves as [find s x] but starts searching
      at offset [ofs]. [find s x] is equivalent to [find_from s 0 x].*)

  val rfind : string -> string -> int option
  (** [rfind s x] returns [Some i], the starting index of the last occurrence
      of string [x] within string [s], or [None] if [x] is not a substring
      of [s].

      {b Note} This implementation is optimized for short strings. *)

  val rfind_from: string -> int -> string -> int option
  (** [rfind_from s ofs x] behaves as [rfind s x] but starts searching
      at offset [ofs]. [rfind s x] is equivalent to
      [rfind_from s (String.length s - 1) x]. *)

  val split : string -> by:string -> (string * string) option
  (** [split s sep] splits the string [s] between the first
      occurrence of [sep], or returns [None] if the separator
      is not found. *)

  val rsplit : string -> by:string -> (string * string) option
    (** [rsplit s sep] splits the string [s] between the last
        occurrence of [sep], or returns [None] if the separator
        is not found. *)

end (* String.Exceptionless *)

(** Capabilities for strings.

    This modules provides the same set of features as {!String}, but
    with the added twist that strings can be made read-only or write-only.
    Read-only strings may then be safely shared and distributed.

    @since 2.8.0 the interface and implementation of the Cap
    module changed to accommodate the -safe-string transition. OCaml
    now uses two distinct types for mutable and immutable string,
    which is a good design but is not as expressive as the present Cap
    interface, and actually makes implementing Cap harder than it
    previously was. We are aware that current state is not optimal for
    heavy Cap users; if you are one of them, please get in touch (on
    the Batteries issue tracker for example) so that we can discuss
    code refactoring and improvements for this sub-module.  *)
module Cap:
sig

  type 'a t
  (** The type of capability strings.

      If ['a] contains [[`Read]], the contents of the string may be read.
      If ['a] contains [[`Write]], the contents of the string may be written.

      Other (user-defined) capabilities may be added without loss of
      performance or features. For instance, a string could be labelled
      [[`Read | `UTF8]] to state that it contains UTF-8 encoded data and
      may be used only for reading.  Conversely, a string labelled with
      [[]] (i.e. nothing) can neither be read nor written. It can only
      be compared for textual equality using OCaml's built-in [compare]
      or for physical equality using OCaml's built-in [==].
  *)

  external length : _ t  -> int = "%string_length"

  val is_empty : _ t -> bool

  external get : [> `Read] t -> int -> char = "%string_safe_get"

  external set : [> `Write] t -> int -> char -> unit = "%string_safe_set"

  external create : int -> _ t = "caml_create_string"

  (** {1 Constructors}*)

  external of_string : Bytes.t -> _ t = "%identity"
##V>=4.2##    [@@ocaml.deprecated "Use Cap.of_bytes instead"]
  (**Adopt a regular byte sequence.

     One could give a perfectly safe semantics to
     an [of_string : string -> _ t] function, but this
     requires making a copy of the string. Previous
     versions of this interface advertised the absence
     of performance overhead, so it's better to warn
     the user and let them decide (through the use of
     either Bytes.of_string or Bytes.unsafe_of_string)
     whether they can safely avoid a copy or need to
     insert one.
   *)

  val of_bytes : Bytes.t -> _ t
  (** Adopt a regular byte sequence.

      Note that adopting a byte sequence, even at the restrictive
      [`Read] type, does not make a copy. Having a [`Read] string
      prevents you (and anyone you pass it to) from writing it, but
      your parent may have knowledge of the string at a more permissive
      type and perform writes on it.

      If you want to use a [`Read] string and assume it will not get
      written to, you should either properly "adopt" it by ensuring
      unique ownership (this cannot be guaranteed by the type system),
      or make a copy of it at adoption time: [Cap.of_bytes
      (Bytes.copy buf)].

      @since 2.8.0
  *)

  external to_string : [`Read | `Write] t -> Bytes.t = "%identity"
##V>=4.2##    [@@ocaml.deprecated "Use Cap.to_bytes instead"]
  (** Return a capability string as a regular byte sequence.

      We cannot return a [string] here, and it would be incorrect to
      do so even if we required [[< `Read] t] as input. Indeed, one
      can start from a writeable byte sequence, and then use the
      [read_only] function below to cast it into a [[`Read]
      t]. Capabilities are used to enforce local protocol (only reads,
      only writes, both reads and writes...), they don't guarantee
      that other users of the same (shared) value all follow the same
      protocol. To safely reason about mutability one needs stronger
      ownership guarantees.

      If you want to obtain an immutable [string] out of a capability
      string, you should first convert it to a mutable byte sequence
      and then copy it into an immutable string. If you have extra
      knowledge about the ownership of the value, you may use unsafe
      conversion functions to avoid the copy, see the documentation of
      unsafe conversion functions.
   *)

  external to_bytes : [`Read | `Write] t -> Bytes.t = "%identity"
  (** Return a capability string as a regular byte sequence.

      @since 2.8.0
  *)

  external read_only : [> `Read] t -> [`Read] t     = "%identity"
  (** Drop capabilities to read only.*)

  external write_only: [> `Write] t -> [`Write] t   = "%identity"
  (** Drop capabilities to write only.*)

  val make : int -> char -> _ t

  val init : int -> (int -> char) -> _ t

  (** {1 Conversions}*)
  val enum : [> `Read] t -> char BatEnum.t

  val of_enum : char BatEnum.t -> _ t

  val backwards : [> `Read] t -> char BatEnum.t

  val of_backwards : char BatEnum.t -> _ t

  val of_list : char list -> _ t

  val to_list : [> `Read] t -> char list

  val of_int : int -> _ t

  val of_float : float -> _ t

  val of_char : char -> _ t

  val to_int : [> `Read] t -> int

  val to_float : [> `Read] t -> float

  (** {1 String traversals}*)

  val map : (char -> char) -> [>`Read] t -> _ t
  val mapi : (int -> char -> char) -> [>`Read] t -> _ t

  val fold_left : ('a -> char -> 'a) -> 'a -> [> `Read] t -> 'a
  val fold_lefti : ('a -> int -> char -> 'a) -> 'a -> [> `Read] t -> 'a

  val fold_right : (char -> 'a -> 'a) -> [> `Read] t -> 'a -> 'a
  val fold_righti : (int -> char -> 'a -> 'a) -> [> `Read] t -> 'a -> 'a

  val filter : (char -> bool) -> [> `Read] t -> _ t

  val filter_map : (char -> char option) -> [> `Read] t -> _ t


  val iter : (char -> unit) -> [> `Read] t -> unit


  (** {1 Finding}*)

  val index : [>`Read] t -> char -> int

  val rindex : [> `Read] t -> char -> int

  val index_from : [> `Read] t -> int -> char -> int

  val rindex_from : [> `Read] t -> int -> char -> int

  val contains : [> `Read] t -> char -> bool

  val contains_from : [> `Read] t -> int -> char -> bool

  val rcontains_from : [> `Read] t -> int -> char -> bool

  val find : [> `Read] t -> [> `Read] t -> int

  val find_from: [> `Read] t -> int -> [> `Read] t -> int

  val rfind : [> `Read] t -> [> `Read] t -> int

  val rfind_from: [> `Read] t -> int -> [> `Read] t -> int

  val ends_with : [> `Read] t -> [> `Read] t -> bool

  val starts_with : [> `Read] t -> [> `Read] t -> bool

  val exists : [> `Read] t -> [> `Read] t -> bool

  val count_char : [> `Read] t -> char -> int

  (** {1 Transformations}*)

  val lchop : ?n:int -> [> `Read] t -> _ t

  val rchop : ?n:int -> [> `Read] t -> _ t

  val chop : ?l:int -> ?r:int -> [> `Read] t -> _ t

  val trim : [> `Read] t -> _ t

  val quote : [> `Read] t -> string

  val left : [> `Read] t -> int -> _ t

  val right : [> `Read] t -> int -> _ t

  val head : [> `Read] t -> int -> _ t

  val tail : [> `Read] t -> int -> _ t

  val strip : ?chars:[> `Read] t -> [> `Read] t -> _ t

##V<5## val uppercase : [> `Read] t -> _ t
##V<5## val lowercase : [> `Read] t -> _ t
##V<5## val capitalize : [> `Read] t -> _ t
##V<5## val uncapitalize : [> `Read] t -> _ t

  val copy : [> `Read] t -> _ t

  val sub : [> `Read] t -> int -> int -> _ t

  val fill : [> `Write] t -> int -> int -> char -> unit

  val blit : [> `Read] t -> int -> [> `Write] t -> int -> int -> unit

  val concat : [> `Read] t -> [> `Read] t list -> _ t

  val escaped : [> `Read] t -> _ t

  val replace_chars : (char -> [> `Read] t) -> [> `Read] t -> _ t

  val replace : str:[> `Read] t -> sub:[> `Read] t -> by:[> `Read] t -> bool * _ t

  val nreplace : str:[> `Read] t -> sub:[> `Read] t -> by:[> `Read] t -> _ t

  val repeat: [> `Read] t -> int -> _ t

  (** {1 Splitting around}*)
  val split : [> `Read] t -> by:[> `Read] t -> _ t * _ t

  val rsplit : [> `Read] t -> by:[> `Read] t -> _ t * _ t

  val nsplit : [> `Read] t -> by:[> `Read] t -> _ t list

  val splice: [ `Read | `Write] t  -> int -> int -> [> `Read] t -> _ t

  val join : [> `Read] t -> [> `Read] t list -> _ t

  val slice : ?first:int -> ?last:int -> [> `Read] t -> _ t

  val explode : [> `Read] t -> char list

  val implode : char list -> _ t

  (** {1 Comparisons}*)

  val compare: [> `Read] t -> [> `Read] t -> int

  val icompare: [> `Read] t -> [> `Read] t -> int


  (** {2 Printing}*)

  val print: 'a BatInnerIO.output -> [> `Read] t -> unit

  val println: 'a BatInnerIO.output -> [> `Read] t -> unit

  val print_quoted: 'a BatInnerIO.output -> [> `Read] t -> unit

  (**/**)

  (** {1 Undocumented operations} *)
  external unsafe_get : [> `Read] t -> int -> char = "%string_unsafe_get"
  external unsafe_set : [> `Write] t -> int -> char -> unit = "%string_unsafe_set"

  external unsafe_blit :
    [> `Read] t -> int -> [> `Write] t -> int -> int -> unit = "caml_blit_string"
##V<4.3##    "noalloc"
##V>=4.3##    [@@noalloc]

  external unsafe_fill : [> `Write] t -> int -> int -> char -> unit = "caml_fill_string"
##V<4.3##    "noalloc"
##V>=4.3##    [@@noalloc]

  (**/**)

  (** Exceptionless counterparts for error-raising operations *)
  module Exceptionless :
  sig
    val to_int : [> `Read] t -> int option

    val to_float : [> `Read] t -> float option

    val index : [>`Read] t -> char -> int option

    val rindex : [> `Read] t -> char -> int option

    val index_from : [> `Read] t -> int -> char -> int option

    val rindex_from : [> `Read] t -> int -> char -> int option

    val find : [> `Read] t -> [> `Read] t -> int option

    val find_from: [> `Read] t -> int -> [> `Read] t -> int option

    val rfind : [> `Read] t -> [> `Read] t -> int option

    val rfind_from: [> `Read] t -> int -> [> `Read] t -> int option

    val split : [> `Read] t -> by:[> `Read] t -> (_ t * _ t) option

    val rsplit : [> `Read] t -> by:[> `Read] t -> (_ t * _ t) option

  end (* String.Cap.Exceptionless *)

end

(**/**)

(* The following is for system use only. Do not call directly. *)

external unsafe_get : string -> int -> char = "%string_unsafe_get"
##V<5##external unsafe_set : Bytes.t -> int -> char -> unit = "%string_unsafe_set"
external unsafe_blit :
  string -> int -> Bytes.t -> int -> int -> unit = "caml_blit_string"
##V<4.3##  "noalloc"
##V>=4.3##  [@@noalloc]
##V<5##external unsafe_fill :
##V<5##  Bytes.t -> int -> int -> char -> unit = "caml_fill_string"
##V<4.3##  "noalloc"
##V<5####V>=4.3##  [@@noalloc]

  (**/**)
