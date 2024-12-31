<template>
  <div class="judge-view">
    <h1>待仲裁的任务</h1>
    <div v-for="(task, index) in disputedTasks" :key="index" class="task-card">
      <div class="task-header">
        <h2>{{ task.title }}</h2>
        <div class="task-info">
          <p>积分: {{ task.points }}</p>
          <p>发布者: {{ task.creator }}</p>
          <p>接受者: {{ task.accepter }}</p>
        </div>
      </div>
      <div class="task-details">
        <p><strong>争议原因:</strong> {{ task.disputedReason }}</p>
        <div class="vote-buttons">
          <button @click="voteForCreator(task.id)" class="btn vote-btn">支持发布者</button>
          <button @click="voteForAccepter(task.id)" class="btn vote-btn">支持接受者</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { getAllTasks, voteDispute } from '../api/contract';

export default {
    data() {
        return {
            disputedTasks: []
        };
    },
    async created() {
        try {
            const allTasks = await getAllTasks();
            this.disputedTasks = allTasks.filter(task => task.isDisputed);
        } catch (error) {
            console.error('获取任务失败', error);
        }
    },
    methods: {
        async voteForCreator(taskId) {
            try {
                await voteDispute(taskId, true, '支持发布者的原因');
                alert('投票成功');
                const allTasks = await getAllTasks();
                this.disputedTasks = allTasks.filter(task => task.isDisputed);
            } catch (error) {
                console.error('投票失败', error);
                alert('投票失败，请检查网络或合约状态');
            }
        },
        async voteForAccepter(taskId) {
            try {
                await voteDispute(taskId, false, '支持接受者的原因');
                alert('投票成功');
                const allTasks = await getAllTasks();
                this.disputedTasks = allTasks.filter(task => task.isDisputed);
            } catch (error) {
                console.error('投票失败', error);
                alert('投票失败，请检查网络或合约状态');
            }
        }
    }
};
</script>

<style scoped>
.judge-view {
    text-align: center;
    margin-top: 50px;
    font-family: Arial, sans-serif;
}

.task-card {
    border: 1px solid #ccc;
    border-radius: 10px;
    padding: 20px;
    margin: 20px auto;
    width: 80%;
    max-width: 600px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    background-color: #f9f9f9;
}

.task-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
}

.task-header h2 {
    margin: 0;
    font-size: 1.5em;
}

.task-info {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
}

.task-info p {
    margin: 5px 0;
    font-size: 1em;
    color: #333;
}

.task-details {
    margin-top: 15px;
    text-align: left;
}

.task-details p {
    margin: 5px 0;
    font-size: 1em;
    color: #333;
}

.vote-buttons {
    margin-top: 15px;
    display: flex;
    justify-content: space-between;
}

.btn {
    background-color: #4CAF50;
    color: white;
    padding: 12px 24px;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    transition: background-color 0.3s;
    font-size: 1em;
}

.btn:hover {
    background-color: #45a049;
}

.vote-btn {
    background-color: #007BFF;
}

.vote-btn:hover {
    background-color: #0056b3;
}
</style>