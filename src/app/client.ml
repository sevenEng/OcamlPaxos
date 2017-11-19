open Core
open Core.Unix
open Lwt.Infix
       
open Types
open Message

module type CLIENT = sig
  type client_info;;
  val new_client : unit -> client_info;;
  val add_replica_uri : Uri.t -> client_info -> client_info;;
  val getid : client_info -> client_id;;
  val getnextcommand : client_info -> command_id;;
  val geturis : client_info -> Uri.t list;;  
  val send_request_message : client_info -> operation -> (command_id * Types.result) Lwt.t list;;
end

module Client : CLIENT = struct
  type client_info = {
    id : client_id;
    next_command_id : command_id;
    replica_uri_list : Uri.t list
  };;

  let getid client = match client with
    | { id; next_command_id; replica_uri_list } -> id;;

  let getnextcommand client = match client with
    | { id; next_command_id; replica_uri_list } -> next_command_id;;
  
  let geturis client = match client with
    | { id; next_command_id; replica_uri_list } -> replica_uri_list;;

  let new_client () = {
    id = Unix.getpid() |> Pid.to_int;
    next_command_id = 1;
    replica_uri_list = []
  };;

  let add_replica_uri uri client = {
    id = getid client;
    next_command_id = getnextcommand client;
    replica_uri_list = uri :: (geturis client)
  };;

  let send_request_message client operation =
    (* Send the message to some underlying RPC subsystem. *)
    let client_id = getid client in
    let command_id = getnextcommand client in
    let replica_uris = geturis client in
    List.map replica_uris (fun uri -> 
        Message.send_request
          (ClientRequestMessage(client_id,command_id,operation)) uri);;
end