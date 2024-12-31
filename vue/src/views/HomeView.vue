<template>
    <div class="home-view">
        <h1>我的任务与资源</h1>

        <!-- 我创建的任务 -->
        <section v-if="createdTasks.length > 0" class="section-container">
            <h2 class="section-title">我创建的任务</h2>
            <div v-for="(task, index) in createdTasks" :key="index" class="task-card">
                <div class="task-header">
                    <h3>{{ task.title }}</h3>
                    <p>状态: {{ getTaskStatus(task) }}</p>
                    <button @click="showTaskDetails(task)" class="btn">详情</button>
                    <button v-if="task.isDisputed === false" @click="submitDispute(task.id)" class="btn dispute-btn">申诉</button>
                </div>
                <div v-if="selectedTask && selectedTask.id === task.id" class="task-details">
                    <p><strong>描述:</strong> {{ task.description }}</p>
                    <p><strong>积分:</strong> {{ task.points }}</p>
                    <p><strong>类型:</strong> {{ task.taskType }}</p>
                    <p><strong>截止时间:</strong> {{ new Date(task.deadline * 1000).toLocaleString() }}</p>
                    <p><strong>接受者:</strong> {{ task.accepter || '尚未接受' }}</p>
                </div>
            </div>
        </section>
        <section v-else class="empty-section">
            <h2 class="section-title">我创建的任务</h2>
            <p>您还没有创建任何任务</p>
        </section>

        <!-- 我发布的资源 -->
        <section v-if="publishedResources.length > 0" class="section-container">
            <h2 class="section-title">我发布的资源</h2>
            <div v-for="(resource, index) in publishedResources" :key="index" class="resource-card">
                <div class="resource-header">
                    <h3>{{ resource.title }}</h3>
                    <p>价格: {{ resource.price }}</p>
                    <button @click="showResourceDetails(resource)" class="btn">详情</button>
                </div>
                <div v-if="selectedResource && selectedResource.id === resource.id" class="resource-details">
                    <p><strong>描述:</strong> {{ resource.description }}</p>
                </div>
            </div>
        </section>
        <section v-else class="empty-section">
            <h2 class="section-title">我发布的资源</h2>
            <p>您还没有发布任何资源</p>
        </section>

        <!-- 我承接的任务 -->
        <section v-if="acceptedTasks.length > 0" class="section-container">
            <h2 class="section-title">我承接的任务</h2>
            <div v-for="(task, index) in acceptedTasks" :key="index" class="task-card">
                <div class="task-header">
                    <h3>{{ task.title }}</h3>
                    <p>状态: {{ getTaskStatus(task) }}</p>
                    <button @click="showTaskDetails(task)" class="btn">详情</button>
                    <button v-if="task.isCompleted === false" @click="completeTask(task.id)" class="btn complete-btn">完成任务</button>
                </div>
                <div v-if="selectedTask && selectedTask.id === task.id" class="task-details">
                    <p><strong>描述:</strong> {{ task.description }}</p>
                    <p><strong>积分:</strong> {{ task.points }}</p>
                    <p><strong>类型:</strong> {{ task.taskType }}</p>
                    <p><strong>截止时间:</strong> {{ new Date(task.deadline * 1000).toLocaleString() }}</p>
                    <p><strong>发布者:</strong> {{ task.creator }}</p>
                </div>
            </div>
        </section>
        <section v-else class="empty-section">
            <h2 class="section-title">我承接的任务</h2>
            <p>您还没有承接任何任务，<a href="#accept-task">点击这里查找并承接任务</a></p>
        </section>
    </div>
</template>

<script>
import {
    getAllTasks,
    getAllResources,
    getAccount,
    submitTaskAsDisputed,
    completeTask as completeTaskWeb3
} from '../api/contract';

export default {
    data() {
        return {
            createdTasks: [],
            publishedResources: [],
            acceptedTasks: [],
            selectedTask: null,
            selectedResource: null
        };
    },
    async created() {
        const account = await getAccount();
        const allTasks = await getAllTasks();
        this.createdTasks = allTasks.filter(task => task.creator === account && !task.isCompleted).map(task => ({
            ...task,
            deadline: task.deadline ? parseInt(task.deadline) : 0
        }));
        this.acceptedTasks = allTasks.filter(task => task.accepter === account && !task.isCompleted).map(task => ({
            ...task,
            deadline: task.deadline ? parseInt(task.deadline) : 0
        }));

        const allResources = await getAllResources();
        this.publishedResources = allResources.filter(resource => resource.owner === account);
    },
    methods: {
        showTaskDetails(task) {
            if (this.selectedTask && this.selectedTask.id === task.id) {
                this.selectedTask = null;
            } else {
                this.selectedTask = task;
            }
        },
        showResourceDetails(resource) {
            if (this.selectedResource && this.selectedResource.id === resource.id) {
                this.selectedResource = null;
            } else {
                this.selectedResource = resource;
            }
        },
        getTaskStatus(task) {
            if (task.isCompleted) {
                return '已完成';
            } else if (task.isMatched) {
                return '进行中';
            } else {
                return '未匹配';
            }
        },
        async submitDispute(taskId) {
            const reason = prompt('请输入申诉原因');
            if (reason) {
                try {
                    await submitTaskAsDisputed(taskId, reason);
                    alert('申诉已提交');
                    await this.refreshCreatedTasks();
                } catch (error) {
                    console.error('申诉失败', error);
                    alert('申诉失败，请检查网络或合约状态');
                }
            }
        },
        async completeTask(taskId) {
            try {
                await completeTaskWeb3(taskId);
                alert('任务已完成');
                await this.refreshAcceptedTasks();
            } catch (error) {
                console.error('完成任务失败', error);
                alert('完成任务失败，请检查网络或合约状态');
            }
        },
        async refreshCreatedTasks() {
            const account = await getAccount();
            const allTasks = await getAllTasks();
            this.createdTasks = allTasks.filter(task => task.creator === account && !task.isCompleted).map(task => ({
                ...task,
                deadline: task.deadline ? parseInt(task.deadline) : 0
            }));
        },
        async refreshAcceptedTasks() {
            const account = await getAccount();
            const allTasks = await getAllTasks();
            this.acceptedTasks = allTasks.filter(task => task.accepter === account && !task.isCompleted).map(task => ({
                ...task,
                deadline: task.deadline ? parseInt(task.deadline) : 0
            }));
        }
    }
};
</script>

<style scoped>
.home-view h2.section-title {
    margin-bottom: 20px;
}

.section-container {
    display: grid;
    gap: 20px; /* 控制各板块间的间距 */
}

.task-card,
.resource-card {
    border: 1px solid #ccc;
    border-radius: 5px;
    padding: 15px;
    margin: 20px auto;
    width: 80%;
    max-width: 600px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.task-header,
.resource-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.task-header h3,
.resource-header h3 {
    margin: 0;
}

.task-header p,
.resource-header p {
    margin: 0;
    font-size: 1em;
    color: #555;
}

.task-details,
.resource-details {
    margin-top: 20px;
    text-align: left;
}

.task-details p,
.resource-details p {
    margin: 5px 0;
    font-size: 1em;
    color: #333;
}

.btn {
    background-color: #4CAF50;
    color: white;
    padding: 10px 20px;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    transition: background-color 0.3s;
}

.btn:hover {
    background-color: #45a049;
}

.dispute-btn {
    background-color: #FF5733;
}

.dispute-btn:hover {
    background-color: #E64A2E;
}

.complete-btn {
    background-color: #007BFF;
}

.complete-btn:hover {
    background-color: #0056b3;
}

.empty-section {
    min-height: 200px; /* 设置最小高度 */
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    background-color: #f9f9f9; /* 轻柔的背景色 */
    border: 1px dashed #ccc; /* 分隔线效果 */
    text-align: center;
}
</style>