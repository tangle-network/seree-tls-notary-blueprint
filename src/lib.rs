use alloy_sol_types::sol;
use gadget_sdk::load_abi;

pub mod constants;
pub mod jobs;
pub mod tlsn;

sol!(
    #[allow(missing_docs)]
    #[allow(clippy::too_many_arguments)]
    #[sol(rpc)]
    SereeServiceManager,
    "contracts/out/SereeServiceManager.sol/SereeServiceManager.json"
);

load_abi!(
    SEREE_SERVICE_MANAGER_ABI,
    "contracts/out/SereeServiceManager.sol/SereeServiceManager.json"
);
