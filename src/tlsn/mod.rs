use gadget_sdk::Error;
use notary_server::{run_server, NotaryServerProperties};

/// Run the TLS Notary server with the given configuration
pub async fn run_tlsn_server(notary_server_props: NotaryServerProperties) -> Result<(), Error> {
    // Spawn the server in a separate task
    let server_handle = tokio::spawn(async move { run_server(&notary_server_props).await });

    // Now you can do other things here while the server runs in background

    // Wait for the server to complete (or error)
    server_handle
        .await
        .map_err(|e| Error::Other(e.to_string()))?
        .map_err(|e| Error::Other(e.to_string()))
}
