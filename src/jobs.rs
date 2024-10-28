use alloy_contract::ContractInstance;
use alloy_json_abi::JsonAbi;
use alloy_network::Ethereum;
use alloy_primitives::FixedBytes;
use alloy_primitives::B256;
use gadget_sdk::{self as sdk};
use sdk::job;
use std::{convert::Infallible, ops::Deref, sync::OnceLock};

use crate::SereeServiceManager;
use crate::SEREE_SERVICE_MANAGER_ABI;

#[derive(Clone)]
pub struct ServiceContext {
    pub config: sdk::config::StdGadgetConfiguration,
}

pub fn noop(_: u32) {}

#[job(
    id = 0,
    params(uuid),
    result(_),
    event_listener(
        listener = EvmContractEventListener(
            instance = SereeServiceManager,
            abi = SEREE_SERVICE_MANAGER_ABI,
        ),
        event = SereeServiceManager::OrderPlaced,
        pre_processor = convert_event_to_inputs,
        post_processor = noop,
    ),
)]
pub fn handle_order_placed(context: ServiceContext, uuid: B256) -> Result<u32, Infallible> {
    println!("Order placed: {:?}", uuid);
    Ok(0)
}

pub fn convert_event_to_inputs(
    event: SereeServiceManager::OrderPlaced,
    _: FixedBytes<32>,
) -> (B256,) {
    (event.uuid,)
}
