// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// 修改CampusAidPlatform合约
contract CampusAidPlatform is ERC20, Ownable {

    uint256 public constant WEI_PER_TOKEN = 100;

    // 铸造功能，仅限合约所有者
    function mint(address to, uint256 amount) external only_Owner {
        _mint(to, amount);
    }

    // 销毁功能，仅限合约所有者
    function burn(uint256 amount) external only_Owner {
        _burn(msg.sender, amount);
    }

    // 购买功能，参与者可以用以太坊购买FishToken
    function buyTokens() external payable {
        require(msg.value > 0, "Must send some ether to buy tokens");
        uint256 tokenAmount = msg.value / WEI_PER_TOKEN;
        require(tokenAmount > 0, "Not enough ether to buy even one token");
        require(balanceOf(owner()) >= tokenAmount, "Not enough tokens available");

        // 将代币从所有者转移到购买者
        _transfer(owner(), msg.sender, tokenAmount);
    }

    // 提取合约中的以太币，仅限合约所有者
    function withdrawEther() external only_Owner {
        payable(owner()).transfer(address(this).balance);
    }

    // 覆写以支持小数点精度
    function decimals() public pure override returns (uint8) {
        return 2; // 100 wei = 1 FTToken
    }

        //仲裁结构体
    struct Arbitration{
        uint taskId;
        address[] votedArbitrators;//已投票仲裁官
        uint favorCreatorCount;//支持发布者票数
        uint favorAccepterCount;//支持接受者票数
    }


    // 任务结构体
    struct Task {
        uint id;  // 任务id，即在tasks中的数组下标
        string title; // 任务标题
        string description; // 任务描述
        uint256 points; // 任务积分
        string taskType; // 任务类型
        uint256 deadline; // 任务截止时间
        address creator; // 发布者地址
        address accepter; // 接受者地址
        bool isMatched; // 是否已匹配
        bool isCompleted; // 是否已完成
        bool isDisputed; // 是否存在争议
        string disputedReason; // 争议原因
    }

    // 学习资源结构体
    struct Resource {
        uint id;  // 资源ID
        string title; // 资源标题
        string description; // 资源描述
        uint256 price; // 资源价格（以代币计）
        address owner; // 资源发布者（默认为合约所有者）
    }

    address[] public arbitrators;//仲裁者地址
    mapping(uint => Arbitration) public arbitrations;//仲裁记录
    mapping(address => bool) public isRegistered; // 用户注册状态映射
    mapping(address => uint256) public creditScores; // 用户信用评分映射
    Task[] public tasks; // 任务列表
    Resource[] public resources; // 学习资源列表

    // 事件定义
    event UserRegistered(address user); // 用户注册事件
    event TaskCreated(uint256 taskId, address creator); // 任务创建事件
    event TaskAccepted(uint256 taskId, address accepter); // 任务接受事件
    event TaskCompleted(uint256 taskId); // 任务完成事件
    event TaskDisputed(uint256 taskId); // 任务争议事件
    event TaskResolved(uint256 taskId, bool favorCreator); // 任务仲裁完成事件
    event ReputationUpdated(address user, uint256 newReputation); // 信誉积分更新事件
    event TaskCancelled(uint256 taskId, address canceller); // 任务取消事件
    event ResourcePublished(uint256 resourceId, string title, uint256 price); // 资源发布事件
    event ResourcePurchased(uint256 resourceId, address buyer); // 资源购买事件
    event ArbitrationVoted(uint taskId, address arbitrator, bool favorCreator);//仲裁者投票事件

    // 仅限合约拥有者的修饰符
    modifier only_Owner() {
        require(msg.sender== Ownable.owner());
        _;
    }

    // 修饰符：检查用户是否注册
    modifier isUserRegistered() {
        require(isRegistered[msg.sender], "User must be registered");
        _;
    }
    //仅限仲裁者的修饰符
    modifier onlyArbitrator(){
        require(isArbitrator(msg.sender), "Only arbitrator can call this");
        _;
    }

    // 修饰符：检查用户信誉积分是否足够
    modifier hasSufficientReputation(uint256 requiredScore) {
        require(creditScores[msg.sender] >= requiredScore, "Insufficient reputation");
        _;
    }

    // 修饰符：检查任务是否匹配
    modifier taskIsMatched(uint256 taskId) {
        Task storage task = tasks[taskId];
        require(task.isMatched, "Task not matched");
        _;
    }

    //检查地址是否为仲裁官
    function isArbitrator(address _addr) public view returns (bool){
        for (uint i=0; i < arbitrators.length; i++) {
            if(arbitrators[i] == _addr) {
                return true;
            }
        }
        return false;
    }

    //设置仲裁者，仅合约拥有者可以调用
    function addArbitrator(address arbitrator) public  only_Owner{
        require(!isArbitrator(arbitrator),"Already an arbitrator");
        arbitrators.push(arbitrator);
    }

    //删除仲裁官，仅合约拥有者可以调用
    function removeArbitrator(address arbitrator) public  only_Owner{
        for (uint i = 0; i < arbitrators.length; i++){
            if (arbitrators[i] == arbitrator){
                arbitrators[i] = arbitrators[arbitrators.length-1];
                arbitrators.pop();
                return;
            }
        }
        revert("Arbitrator not found");
    }

    // 构造函数

    constructor() ERC20("PointToken", "Point") Ownable(msg.sender) {
        arbitrators.push(Ownable.owner());
        // 铸造初始供应量的代币，并将其分配给合约所有者
        _mint(msg.sender, 1000 * 10 ** decimals());

     }

    // 注册用户
    function register() public {
        require(!isRegistered[msg.sender], "User already registered");
        isRegistered[msg.sender] = true;
        creditScores[msg.sender] = 100;  // 初始信誉积分为100
        emit UserRegistered(msg.sender);
    }

    // 获取任务总数
    function getTaskCount() public view returns (uint256) {
        return tasks.length;
    }

    
    // 获取资源总数
    function getResourceCount() public view returns (uint256) {
        return resources.length;
    }

    // //获取争议任务总数
    // function getArbitrationsCount() public view returns (uint256) {
    //     return arbitrations.length;
    // }


    // 发布学习资源
    function publishResource(string memory title, string memory description, uint256 price) public isUserRegistered() {
        require(price > 0, "Price must be greater than zero");

        resources.push(
            Resource({
                id: resources.length,
                title: title,
                description: description,
                price: price,
                owner: msg.sender
            })
        );

        emit ResourcePublished(resources.length - 1, title, price);
    }


    // 购买学习资源
    function purchaseResource(uint256 resourceId) public {
        require(resourceId < resources.length, "Invalid resource ID");
        Resource storage resource = resources[resourceId];
        require(balanceOf(msg.sender) >= resource.price, "Insufficient tokens");

        _transfer(msg.sender, resource.owner, resource.price);

        resource.owner = msg.sender;

        emit ResourcePurchased(resourceId, msg.sender);
    }

    // 查询用户拥有的学习资源
    function getOwnedResources() public view returns (Resource[] memory) {
        uint256 count = 0;

        for (uint256 i = 0; i < resources.length; i++) {
            if (resources[i].owner == msg.sender) {
                count++;
            }
        }

        Resource[] memory ownedResources = new Resource[](count);
        uint256 j = 0;

        for (uint256 i = 0; i < resources.length; i++) {
            if (resources[i].owner == msg.sender) {
                ownedResources[j] = resources[i];
                j++;
            }
        }

        return ownedResources;
    }

    // 查询所有学习资源
    function getAllResources() public view returns (Resource[] memory) {
        return resources;
    }

    // 创建任务
    function createTask(
        string memory title,
        string memory description,
        uint256 points,
        string memory taskType,
        uint256 deadline
    ) public isUserRegistered hasSufficientReputation(60) {
        require(balanceOf(msg.sender) >= points, "Insufficient points");

        _transfer(msg.sender, address(this), points);

        tasks.push(
            Task({
                id: tasks.length,
                title: title,
                description: description,
                points: points,
                taskType: taskType,
                deadline: deadline,
                creator: msg.sender,
                accepter: address(0),
                isMatched: false,
                isCompleted: false,
                isDisputed: false,
                disputedReason: ""
            })
        );

        emit TaskCreated(tasks.length - 1, msg.sender);
    }

    // 接受任务
    function acceptTask(uint256 taskId) public isUserRegistered hasSufficientReputation(60) {
        Task storage task = tasks[taskId];
        require(!task.isMatched, "Task already matched");
        require(msg.sender!= task.creator, "Can't accept the task published by yourself!");
        require(balanceOf(msg.sender) >= task.points * 2, "The remaining points are insufficient to pay the deposit.!");

        _transfer(msg.sender, address(this), task.points * 2);

        task.accepter = msg.sender;
        task.isMatched = true;

        emit TaskAccepted(taskId, msg.sender);
    }

    // 完成任务
    function completeTask(uint256 taskId) public taskIsMatched(taskId) {
        Task storage task = tasks[taskId];
        require(msg.sender == task.accepter, "Not authorized");
        require(!task.isCompleted, "Task already completed");

        task.isCompleted = true;

        _transfer(address(this), task.accepter, task.points);
        _transfer(address(this), task.accepter, task.points * 2);

        // 完成任务后加10信誉积分，最高不超过100
        if (creditScores[task.accepter] < 100) {
            creditScores[task.accepter] = (creditScores[task.accepter] + 10 > 100)? 100 : creditScores[task.accepter] + 10;
            emit ReputationUpdated(task.accepter, creditScores[task.accepter]);
        }

        emit TaskCompleted(taskId);
    }

    // 取消任务函数（发布者或接受者可调用）
    function cancelTask(uint256 taskId) public taskIsMatched(taskId) {
        Task storage task = tasks[taskId];
        require(msg.sender == task.creator || msg.sender == task.accepter, "Only creator or accepter can cancel");

        // 扣除5点信誉积分
        creditScores[msg.sender] = (creditScores[msg.sender] >= 5)? creditScores[msg.sender] - 5 : 0;
        emit ReputationUpdated(msg.sender, creditScores[msg.sender]);

        // 退还押金
        _transfer(address(this), task.creator, task.points * 2);

        task.isMatched = false; // 任务匹配状态改为未匹配
        emit TaskCancelled(taskId, msg.sender);
    }

    // 查询所有我创建的任务
    function getTasksCreateByMe() public view returns (Task[] memory) {
        uint256 count = 0;

        // 计算由我创建的任务的数量
        for (uint256 i = 0; i < tasks.length; i++) {
            if (tasks[i].creator == msg.sender) {
                count++;
            }
        }

        // 创建一个新的数组来存储我创建的任务
        Task[] memory myTasks = new Task[](count);
        uint256 j = 0;

        // 将我创建的任务添加到新数组
        for (uint256 i = 0; i < tasks.length; i++) {
            if (tasks[i].creator == msg.sender) {
                myTasks[j] = tasks[i];
                j++;
            }
        }
        return myTasks;
    }

    //对某个自己发布的任务提出有争议
    function submitTaskAsDisputed(uint256 taskIndex, string memory reason) public taskIsMatched(taskIndex) {
        Task storage task = tasks[taskIndex];
        require(task.creator == msg.sender, "The task ID is wrong. You didn't publish the task!");
        require(!task.isDisputed, "Task already disputed");

        task.isDisputed = true;
        task.disputedReason = reason;
        emit TaskDisputed(taskIndex);
    }

 // 仲裁官投票
    function voteDispute(uint taskId, bool favorCreator) public onlyArbitrator {
        Arbitration storage arbitration = arbitrations[taskId];
        Task storage task = tasks[taskId];
        require(task.isDisputed, "Task is not disputed");
        require(!hasVoted(taskId, msg.sender), "Arbitrator already voted");

        arbitration.votedArbitrators.push(msg.sender);
        if (favorCreator) {
            arbitration.favorCreatorCount++;
        } else {
            arbitration.favorAccepterCount++;
        }

        emit ArbitrationVoted(taskId, msg.sender, favorCreator);

        // 判断是否过半支持任一方
        uint requiredVotes = (arbitrators.length + 1) / 2; // 过半票数
        if (arbitration.favorCreatorCount >= requiredVotes || arbitration.favorAccepterCount >= requiredVotes) {
            finalizeDispute(taskId);
        }
    }

    // 检查仲裁官是否已投票
    function hasVoted(uint taskId, address arbitrator) public view returns (bool) {
        Arbitration storage arbitration = arbitrations[taskId];
        for (uint i = 0; i < arbitration.votedArbitrators.length; i++) {
            if (arbitration.votedArbitrators[i] == arbitrator) {
                return true;
                }
            }
        return false;
    }

    // 完成仲裁
    function finalizeDispute(uint taskId) internal {
        Arbitration storage arbitration = arbitrations[taskId];
        Task storage task = tasks[taskId];
        require(!task.isCompleted, unicode"该任务已完成！");
        require(task.isDisputed, unicode"该任务暂无争议！");
        if (arbitration.favorCreatorCount > arbitration.favorAccepterCount) {
            // 仲裁支持发布者
            _transfer(task.accepter,task.creator,task.points * 3);// 发布者获得押金
            creditScores[task.accepter]--;
        } else {
            // 仲裁支持接受者
            //_transfer(address(this),task.accepter,task.points * 2);// 发布者获得押金
            creditScores[task.creator]--;
        }

        task.isDisputed = false;
        emit TaskResolved(taskId, arbitration.favorCreatorCount > arbitration.favorAccepterCount);
    }


    // 查询所有未匹配的任务
    function getUnMatchedTasks() public view returns (uint256,Task[] memory) {
        uint256 count = 0;

        for (uint256 i = 0; i < tasks.length; i++) {
            if (!tasks[i].isMatched) {
                count++;
            }
        }

        Task[] memory unMatchedTasks = new Task[](count);
        uint256 j = 0;

        for (uint256 i = 0; i < tasks.length; i++) {
            if (!tasks[i].isMatched) {
                unMatchedTasks[j] = tasks[i];
                j++;
            }
        }

        return (count,unMatchedTasks);
    }

    // 查询所有有争议的任务
    function getDisputedTasks() public view returns (uint256,Task[] memory) {
        uint256 count = 0;

        for (uint256 i = 0; i < tasks.length; i++) {
            if (tasks[i].isDisputed) {
                count++;
            }
        }

        Task[] memory disputedTasks = new Task[](count);
        uint256 j = 0;

        for (uint256 i = 0; i < tasks.length; i++) {
            if (tasks[i].isDisputed) {
                disputedTasks[j] = tasks[i];
                j++;
            }
        }
        return (count,disputedTasks);
    }

    // 查询某个用户的信誉积分
    function getReputation(address user) public view returns (uint256) {
        return creditScores[user];
    }
}
    