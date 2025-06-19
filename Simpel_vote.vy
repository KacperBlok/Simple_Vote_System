# Kontrakt prostego systemu głosowania w Vyper

contract Voting:
    active: public(bool)
    
    struct Candidate:
        name: string
        vote_count: uint256
    
    candidates: public(map(uint256, Candidate))
    
    voters: public(map(address, bool))
    
    candidate_count: public(uint256)
    
    total_votes: public(uint256)
    
    @public
    @nonpayable
    def __init__():
        self.active = True
        self.candidate_count = 0
        self.total_votes = 0
    
    @public
    @nonpayable
    def register_candidate(name: string):
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
        
        self.candidates[candidate_id].vote_count += 1
        self.total_votes += 1
        
        self.voters[msg.sender] = False
    
    @public
    @nonpayable
    def end_voting():
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
