
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Types "Types";
import {recurringTimer } = "mo:base/Timer";

actor {
  var array: [Text] = []; // Use 'var' to make 'array' mutable


  public query func dataHistory() : async [Text] {
    return array;
  };

  public query func transform(raw : Types.TransformArgs) : async Types.CanisterHttpResponsePayload {
    let transformed : Types.CanisterHttpResponsePayload = {
      status = raw.response.status;
      body = raw.response.body;
      headers = [
        { name = "Content-Security-Policy"; value = "default-src 'self'" },
        { name = "Referrer-Policy"; value = "strict-origin" },
        { name = "Permissions-Policy"; value = "geolocation=(self)" },
        { name = "Strict-Transport-Security"; value = "max-age=63072000" },
        { name = "X-Frame-Options"; value = "DENY" },
        { name = "X-Content-Type-Options"; value = "nosniff" },
      ];
    };
    transformed;
  };

  public func get_icp_usd_exchange() : async Text {
    let ic : Types.IC = actor ("aaaaa-aa");
    let host : Text = "api.coinbase.com";
    let url = "https://" # host # "/v2/prices/ICP-USD/spot";

    let request_headers = [
      { name = "Host"; value = host # ":443" },
      { name = "User-Agent"; value = "exchange_rate_canister" },
    ];

    let transform_context : Types.TransformContext = {
      function = transform;
      context = Blob.fromArray([]);
    };

    let http_request : Types.HttpRequestArgs = {
      url = url;
      max_response_bytes = null;
      headers = request_headers;
      body = null;
      method = #get;
      transform = ?transform_context;
    };

    Cycles.add<system>(20_949_972_000);

    let http_response : Types.HttpResponsePayload = await ic.http_request(http_request);

    // Decode the response body to a string and return it as-is
    let response_body : Blob = Blob.fromArray(http_response.body);
    let decoded_text : Text = switch (Text.decodeUtf8(response_body)) {
      case (null) { "No value returned" };
      case (?y) {
        // Append decoded_text to array if it's not null
        array := Array.append<Text>(array, [y]);
        y;
      };
    };

    decoded_text;
  };

  private func recurringcalls(): async() {
    let text = await get_icp_usd_exchange();
  };

  ignore recurringTimer<system>(#seconds 1200, recurringcalls);
};
