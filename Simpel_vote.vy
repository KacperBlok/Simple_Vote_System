owner: public(address)

active: public(bool)

struct Candidate:
    name: string
    vote_count: uint256

candidates: public(map(uint256, Candidate))

voters: public(map(address, bool))

candidate_count: public(uint256)

total_votes: public(uint256)

voting_end_time: public(uint256)

token_holding_time: public(map(address, uint256))

token_address: public(address)

@public
@nonpayable
def __init__(voting_duration: uint256, token_addr: address):
    self.owner = msg.sender
    self.active = True
    self.candidate_count = 0
    self.total_votes = 0
    self.voting_end_time = block.timestamp + voting_duration
    self.token_address = token_addr

@public
@nonpayable
def register_candidate(name: string):
    assert msg.sender == self.owner, "Only owner can register candidates."
    assert self.active, "Voting is not active."
    self.candidates[self.candidate_count] = Candidate({name: name, vote_count: 0})
    self.candidate_count += 1

@public
@nonpayable
def register_voter():
    assert self.active, "Voting is not active."
    assert not self.voters[msg.sender], "You have already voted."
    self.voters[msg.sender] = True

@public
@nonpayable
def vote(candidate_id: uint256):
    assert self.active, "Voting is not active."
    assert self.voters[msg.sender], "You are not registered to vote."
    assert candidate_id < self.candidate_count, "Candidate does not exist."
    
    token_balance: uint256 = ERC20(self.token_address).balanceOf(msg.sender)
    assert token_balance > 1, "You must hold more than 1 token to vote."
    
    holding_time: uint256 = block.timestamp - self.token_holding_time[msg.sender]
    assert holding_time >= 604800, "You must hold tokens for at least 7 days."

    self.candidates[candidate_id].vote_count += token_balance
    self.total_votes += token_balance
    self.voters[msg.sender] = False

@public
@nonpayable
def end_voting():
    assert block.timestamp >= self.voting_end_time, "Voting is still ongoing."
    self.active = False

@public
@nonpayable
def get_results() -> string:
    assert not self.active, "Voting is still active."
    
    winning_candidate_id: uint256 = 0
    for i in range(self.candidate_count):
        if self.candidates[i].vote_count > self.candidates[winning_candidate_id].vote_count:
            winning_candidate_id = i
    
    return self.candidates[winning_candidate_id].name
