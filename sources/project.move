module MyModule::NFT_Governance {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a governance proposal
    struct Proposal has key, store {
        id: u64,              // Proposal ID
        description: vector<u8>, // Proposal description
        votes_for: u64,       // Votes in favor of the proposal
        votes_against: u64,   // Votes against the proposal
        quorum: u64,          // Required quorum for the proposal to pass
        is_passed: bool,      // Whether the proposal has passed
    }

    /// Struct representing the governance token holder
    struct Voter has key, store {
        address: address,    // Address of the voter
        voted: bool,         // Whether the voter has already voted
    }

    const GOVERNANCE_TOKEN: u64 = 1000; // Placeholder for governance token count

    /// Function to create a new governance proposal
    public fun create_proposal(owner: &signer, proposal_id: u64, description: vector<u8>, quorum: u64) {
        let proposal = Proposal {
            id: proposal_id,
            description,
            votes_for: 0,
            votes_against: 0,
            quorum,
            is_passed: false,
        };
        move_to(owner, proposal); // Store the proposal in the owner's account
    }

    /// Function for users to vote on a proposal
    public fun vote_on_proposal(voter: &signer, proposal_owner: address, vote: bool) acquires Proposal, Voter {
        // Extract address from signer to pass it to borrow_global_mut
        let voter_address = signer::address_of(voter);

        // Borrow the proposal and voter data
        let proposal = borrow_global_mut<Proposal>(proposal_owner);
        let voter_data = borrow_global_mut<Voter>(voter_address);

        // Ensure the voter hasn't voted yet
        if (voter_data.voted) {
            return;
        };

        // Update vote counts based on user's vote
        if (vote) {
            proposal.votes_for = proposal.votes_for + GOVERNANCE_TOKEN;
        } else {
            proposal.votes_against = proposal.votes_against + GOVERNANCE_TOKEN;
        };

        // Mark voter as voted
        voter_data.voted = true;

        // Check if the proposal has passed based on quorum
        if (proposal.votes_for > proposal.quorum) {
            proposal.is_passed = true;
        };
    }
}
