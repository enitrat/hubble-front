%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256
from starknet.graph.graph import build_graph
from starknet.graph.dfs_search import init_dfs
from starknet.data_types.data_types import Pair, Node
from starknet.contracts.hubble_library import Hubble, get_node_from_token
from starkware.cairo.common.memcpy import memcpy

const JEDI_ROUTER = 19876081725
const JEDI_FACTORY = 1786125

const TOKEN_A = 123
const TOKEN_B = 456
const TOKEN_C = 990
const TOKEN_D = 982

const RESERVE_A_B_0_LOW = 27890
const RESERVE_A_B_1_LOW = 26789

const PAIR_A_B = 12345
const PAIR_A_C = 13345
const PAIR_B_C = 23456
const PAIR_D_C = 43567
const PAIR_D_B = 42567

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    amm_wrapper_contract : felt
):
    Hubble.initializer(amm_wrapper_contract)
    return ()
end

@view
func get_all_routes{range_check_ptr}(token_from : felt, token_to : felt, max_hops : felt) -> (
    routes_len : felt, routes : felt*
):
    alloc_locals
    let (local parsed_pairs : Pair*) = alloc()
    let parsed_pairs_len = 5
    assert parsed_pairs[0] = Pair(TOKEN_A, TOKEN_B)
    assert parsed_pairs[1] = Pair(TOKEN_A, TOKEN_C)
    assert parsed_pairs[2] = Pair(TOKEN_B, TOKEN_C)
    assert parsed_pairs[3] = Pair(TOKEN_D, TOKEN_C)
    assert parsed_pairs[4] = Pair(TOKEN_D, TOKEN_B)
    let (graph_len, graph, neighbors) = build_graph(pairs_len=parsed_pairs_len, pairs=parsed_pairs)
    let node_from = graph[0]
    let node_to = graph[3]
    let (saved_paths_len, saved_paths) = init_dfs(
        graph_len, graph, neighbors, node_from, node_to, 4
    )
    return (saved_paths_len, saved_paths)
end

@view
func get_pairs{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    pairs_len : felt, pairs : Pair*
):
    alloc_locals
    let (local parsed_pairs : Pair*) = alloc()
    let parsed_pairs_len = 5
    assert parsed_pairs[0] = Pair(TOKEN_A, TOKEN_B)
    assert parsed_pairs[1] = Pair(TOKEN_A, TOKEN_C)
    assert parsed_pairs[2] = Pair(TOKEN_B, TOKEN_C)
    assert parsed_pairs[3] = Pair(TOKEN_D, TOKEN_C)
    assert parsed_pairs[4] = Pair(TOKEN_D, TOKEN_B)
    return (parsed_pairs_len, parsed_pairs)
end

@view
func get_best_routes{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    n_routes : felt, amount_in : Uint256, token_from : felt, token_to : felt, max_hops : felt
) -> (route_len : felt, route : felt*):
    alloc_locals
    let (all_routes_len, all_routes) = get_all_routes(token_from, token_to, max_hops)
    let (local res : felt*) = alloc()
    let (res_len) = add_route_to_res(
        remaining_routes=n_routes,
        all_routes_len=all_routes_len,
        all_routes=all_routes,
        res_len=0,
        res=res,
    )
    return (res_len, res)
end

func add_route_to_res{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    remaining_routes : felt, all_routes_len : felt, all_routes : felt*, res_len : felt, res : felt*
) -> (res_len : felt):
    if remaining_routes == 0:
        return (res_len)
    end
    let current_len = all_routes[0]
    let (res_len) = copy_route(res_len, res, current_len, all_routes + 1)
    return add_route_to_res(
        remaining_routes - 1,
        all_routes_len - current_len - 1,
        all_routes + 1 + current_len,
        res_len,
        res,
    )
end

func copy_route{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    res_len : felt, res : felt*, route_len : felt, route : felt*
) -> (res_len : felt):
    memcpy(res + res_len, route, route_len)
    return (res_len + route_len)
end

# @view
# func get_best_route_mock{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
#     amount_in : Uint256, token_from : felt, token_to : felt, max_hops : felt
# ) -> (route_len : felt, route : felt*):
#     alloc_locals
#     let (routes_len : felt, routes : felt*) = get_best_route_mock(
#         amount_in, token_from, token_to, max_hops
#     )

# # for demo we send 1 and 2

# let (best_route_len, best_route, amount_out) = Hubble._get_best_route(
#         amount_in, saved_paths_len, saved_paths, 0, best_route
#     )
#     return (best_route_len, best_route, amount_out)
# end
