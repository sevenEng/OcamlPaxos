open! Core
open! Async
open Types

val logger : Async_unix.Log.t
(** Logging source *)

type t

val op_read : t -> bytes -> op_result Deferred.t
(** [op_read t k] reads the value stored in [k] it will retry until there is a value stored there *)

val op_write : t -> k:bytes -> v:bytes -> op_result Deferred.t
(** [op_write t k v] writes [v] to key [k] *)

val new_client :
  ?connection_retry:Time.Span.t -> ?retry_delay:Time.Span.t -> string list -> t
(** [new_client addresses] Creates a new client connected to the servers listed in [addresses]. If a server is unreachable it will keep trying to reconnect to it. *)

val close : t -> unit Deferred.t
(** [close t] closes all outgoing connections that t has. *)
