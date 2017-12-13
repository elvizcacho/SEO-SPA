vcl 4.0;


backend default {
    .host = "haproxy";
    .port = "80";
}

sub vcl_hash {
    hash_data(req.http.User-Agent);
    hash_data(req.url);
    return (lookup);
}

sub vcl_recv {
    return(hash);
}

sub vcl_backend_response {
  set beresp.grace = 2m;
}

sub vcl_hit {
   if (obj.ttl >= 0s) {
       // A pure unadultered hit, deliver it
       return (deliver);
   }
   if (obj.ttl + obj.grace > 0s) {
       // Object is in grace, deliver it
       // Automatically triggers a background fetch
       return (deliver);
   }
   // fetch & deliver once we get the result
   return (fetch);
}
