use color_eyre::Result;
use gadget_sdk as sdk;
use gadget_sdk::job_runner::MultiJobRunner;
use notary_server::NotaryServerProperties;
use tls_notary_blueprint::tlsn::run_tlsn_server;

#[sdk::main(env)]
async fn main() -> Result<()> {
    init_logger();
    let _notary_server_props = NotaryServerProperties {
        server: todo!(),
        notarization: todo!(),
        tls: todo!(),
        notary_key: todo!(),
        logging: todo!(),
        authorization: todo!(),
    };
    run_tlsn_server(_notary_server_props).await?;

    tracing::info!("Starting the event watcher ...");
    MultiJobRunner::new(env).run().await?;

    tracing::info!("Exiting...");
    Ok(())
}

fn init_logger() {
    let env_filter = tracing_subscriber::EnvFilter::from_default_env();
    tracing_subscriber::fmt()
        .compact()
        .with_target(true)
        .with_env_filter(env_filter)
        .init();
}
