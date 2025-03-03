import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure can create and vote on proposal with proper validation",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    // Create proposal with invalid deadline
    let block = chain.mineBlock([
      Tx.contractCall(
        "governance",
        "create-proposal",
        [
          types.uint(1), // property-id
          types.utf8("Test proposal"),
          types.uint(1) // invalid deadline (past)
        ],
        deployer.address
      ),
    ]);
    
    assertEquals(block.receipts[0].result.expectErr(), 106);
    
    // Create valid proposal
    block = chain.mineBlock([
      Tx.contractCall(
        "governance",
        "create-proposal",
        [
          types.uint(1), // property-id
          types.utf8("Test proposal"),
          types.uint(100) // valid future deadline
        ],
        deployer.address
      ),
    ]);
    
    assertEquals(block.receipts[0].result.expectOk().expectUint(1));
    
    // Vote on proposal
    block = chain.mineBlock([
      Tx.contractCall(
        "governance",
        "vote-on-proposal",
        [
          types.uint(1), // proposal-id
          types.uint(100), // amount
          types.bool(true) // vote-for
        ],
        wallet1.address
      ),
    ]);
    
    assertEquals(block.receipts[0].result.expectOk().expectBool(true));
  },
});
