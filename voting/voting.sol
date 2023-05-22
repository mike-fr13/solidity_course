// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.18;

//import "./node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Voting is Ownable {

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    // id de la proposition gagnante
    uint internal winningProposalId;

    // liste des adress whitelisted
    mapping(address => Voter) internal whitelistedVoters;

    //liste des propositions
    Proposal[] internal  proposals;

    //status du vote à l'instant T
    WorkflowStatus public  currentStatus;
    
    event Whitelisted(address _address);
    event AllreadyWhitelisted(address _address);
    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    /*
    Ce constructeur initialise le contrat;
    J'ai pris le choix :
        - d'ajouter l'adresse de l'admin à la whitelist 
        - d'initialiser directement le statut du vote à RegisteringVoters
    */
    constructor (){
        //ajout à la whitelist de l'administrateur déployant le contrat 
        whitelistedVoters[msg.sender] = Voter(true,false,0);

        //on initialiser le statut à RegisteringVoters afin debuter le cycle de vote
        currentStatus = WorkflowStatus.RegisteringVoters;
    }

    // check si l'adresse est bien whitelistée
    modifier whitelisted(address _address) {
        require(whitelistedVoters[_address].isRegistered,"l'adresse n'est pas dans la whitelist");
        _;
    }

    /*
        Ce modifier verifie si qu'une adresse n'est pas déjà dans la whitelist 
            - si l'address n'est pas présente, le traitement de la fonction appellelante se poursuit
            - sinon il emet un evenement AllreadyWhitelisted et skip la fonction appelante

        C'est utlisé dans le cas de l'import d'adresse à whitlelister avec la fonction bacthAuthorize qui prend une liste d'adresse en entrée.
        Si une addrese de la liste est déjà whitelisté, on itère quand meme sur la suite de la liste.
    */
    modifier notWhitelisted(address _address) {
        if (!whitelistedVoters[_address].isRegistered) {
            _;
        } else {
            emit AllreadyWhitelisted(_address);
        }
    }

    // vérifie que le statut courant est RegisteringVoters
    modifier registeringVoters() {
        require(currentStatus==WorkflowStatus.RegisteringVoters,"Voters registration period must be opened");
        _;
    }
    // vérifie que le statut courant est ProposalsRegistrationStarted
    modifier proposalsRegistrationStarted() {
        require(currentStatus==WorkflowStatus.ProposalsRegistrationStarted,"Proposal registration period must be opened");
        _;
    }
    // vérifie que le statut courant est ProposalsRegistrationEnded
    modifier proposalsRegistrationEnded() {
        require(currentStatus==WorkflowStatus.ProposalsRegistrationEnded,"Proposal registration period must be closed");
        _;
    }
    // vérifie que le statut courant est VotingSessionStarted
    modifier votingSessionStarted() {
        require(currentStatus==WorkflowStatus.VotingSessionStarted,"Voting period must be opened");
        _;
    }
    // vérifie que le statut courant est VotingSessionEnded
    modifier votingSessionEnded() {
        require(currentStatus==WorkflowStatus.VotingSessionEnded,"Voting period must be closed");
        _;
    }
    // vérifie que le statut courant est VotesTallied
    modifier votesTallied() {
        require(currentStatus==WorkflowStatus.VotesTallied,"Votes must be tallied");
        _;
    }

    // change le status courrant et emet un evenement WorkflowStatusChange
    function changeStatusAndEmitEvent(WorkflowStatus _newStatus) private onlyOwner{
        WorkflowStatus oldstatus = currentStatus;
        currentStatus = _newStatus;
        emit WorkflowStatusChange(oldstatus,currentStatus);
    }

    //L'administrateur du vote commence la session d'enregistrement de la proposition.
    function startProposalRegistration() public onlyOwner registeringVoters{
         changeStatusAndEmitEvent(WorkflowStatus.ProposalsRegistrationStarted);
    }
    //L'administrateur de vote met fin à la session d'enregistrement des propositions.
    function endProposalRegistration() public onlyOwner proposalsRegistrationStarted {
         changeStatusAndEmitEvent(WorkflowStatus.ProposalsRegistrationEnded);
    }
    //L'administrateur du vote commence la session de vote.
    function startVotingSession() public onlyOwner proposalsRegistrationEnded{
         changeStatusAndEmitEvent(WorkflowStatus.VotingSessionStarted);
    }
    //L'administrateur du vote met fin à la session de vote.
    function endVotingSession() public onlyOwner votingSessionStarted{
         changeStatusAndEmitEvent(WorkflowStatus.VotingSessionEnded);
    }
    //L'administrateur du vote comptabilise les votes.
    function tallyVotes() public onlyOwner votingSessionEnded{
        winningProposalId = searchWinnerIndex();
        changeStatusAndEmitEvent(WorkflowStatus.VotesTallied);
    }

    /*
        - ajoute une adresse à la whitelist si celle ci n'a pas déjà été whitelistée 
        - emet soit un event Whitelisted, soit un event AllreadyWhitelisted (si l'adresse est déjà présente)
    */
    function authorize(address _address) public onlyOwner registeringVoters notWhitelisted(_address) {
            whitelistedVoters[_address] = Voter(true,false,0);
            emit Whitelisted(_address);
     }

    /*
        - ajoute une liste d'adresses à la whitelist 
        - se base sur la fonction authorize
    */
    function batchAuthorize(address[] calldata _addresses) public onlyOwner registeringVoters {
            require(_addresses.length > 0,"adress array parameter is empty");
            for (uint i=0; i< _addresses.length; i++) {
                authorize(_addresses[i]);
            }
     }     


    /*
        Ajout d'une proposition
        emet un event ProposalRegistered
    */
    function registerProposal(string memory _description) public proposalsRegistrationStarted whitelisted(msg.sender) {
        require(!(bytes(_description).length == 0),"La description de proposition ne peut etre vide");
        proposals.push(Proposal(_description,0));
        emit ProposalRegistered(proposals.length);
    }

    /* 
        ajout d'un vote sur une proposition pour une personne whitelistée n'ayant pas déjà voté
        emet un event Voted
    */
    function vote(uint _proposalId) public votingSessionStarted whitelisted(msg.sender) {
        require(_proposalId <= proposals.length,"Cet identifiant de proposition n'existe pas");
        require(!whitelistedVoters[msg.sender].hasVoted,"Vous avez deja vote");
        proposals[_proposalId].voteCount ++;
        whitelistedVoters[msg.sender].hasVoted = true;
        whitelistedVoters[msg.sender].votedProposalId = _proposalId;
        emit Voted(msg.sender, _proposalId);
    }

    
    //recherche l'index de la proposition gagnante
    function searchWinnerIndex() internal view onlyOwner votingSessionEnded returns (uint winningProposalIndex) {
        uint currentVoteCount;
        for (uint i=0; i < proposals.length; i++) {
            if (proposals[i].voteCount > currentVoteCount) {
                currentVoteCount = proposals[i].voteCount;
                winningProposalIndex=i;
            }
        }
    }

    //Tout le monde peut vérifier les derniers détails de la proposition gagnante.
    function getWinner() public view votesTallied returns (Proposal memory) {
        Proposal memory winingProposal = proposals[winningProposalId];
        return (winingProposal);
     }

    /* Ce getter permet de retourner tout le tableau de proposals 
       Lorsque l'on met uniquement la variable proposals en public, remix nous propose uniquement de recuperer element par element
       en demandant l'index de l'element en parametre du getter.
    */
     function getProposals() public view returns (Proposal[] memory) {
         return proposals;
     }
}