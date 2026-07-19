mod datalog;
mod gate;
mod plasma;

use axum::{routing::{get, post}, Router};
use std::net::SocketAddr;
use tokio::net::TcpListener;
use tracing::info;

async fn health() -> &'static str {
    "sovereign-transformer: ok"
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let port: u16 = std::env::var("TRANSFORMER_PORT")
        .ok()
        .and_then(|p| p.parse().ok())
        .unwrap_or(3778);

    let app = Router::new()
        .route("/health", get(health))
        .route("/gate", post(gate::handle));

    let addr = SocketAddr::from(([0, 0, 0, 0], port));
    info!("Sovereign transformer listening on {}", addr);

    let listener = TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
