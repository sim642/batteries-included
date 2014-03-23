(*
 * BatEnum - Enumeration over abstract collection of elements.
 * Copyright (C) 2003 Nicolas Cannasse
 *               2009 David Rajchenbach-Teller, LIFO, Universite d'Orleans
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

(** General purpose combinators *)

let on f g x y = f (g x) (g y)

let finally handler f x =
  let r = (
    try
      f x
    with
      e -> handler(); raise e
  ) in
  handler();
  r

let with_dispose ~dispose f x =
  finally (fun () -> dispose x) f x

let forever f x = ignore (while true do f x done)

let ignore_exceptions f x = try ignore (f x) with _ -> ()


  (** {6 Operators}*)

 let ( |> ) x f = f x
 external (|>) : 'a -> ('a -> 'b) -> 'b = "%revapply"

 let ( @@ ) f x = f x
 external ( @@ ) : ('a -> 'b) -> 'a -> 'b = "%apply"

let ( %> ) f g x = g (f x)

let ( % ) f g x = f (g x)

let flip f x y = f y x

let curry f x y = f (x,y)

let uncurry f (x,y) = f x y

let const x _ = x

let neg p x = not (p x)

let neg2 p x y = not (p x y)

external identity : 'a -> 'a = "%identity"

let tap f x = f x; x

let ( |? ) = BatOption.Infix.( |? )

let verify_arg x s = if x then () else invalid_arg s

let undefined ?(message="Undefined") _ = failwith message
(*$T undefined
   ignore (Obj.magic (undefined ~message:"")); true
   try ignore (undefined ~message:"FooBar" ()); false with Failure "FooBar" -> true
*)