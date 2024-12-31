<template>
  <div class="tasks">
    <h1>所有任务</h1>
    <div v-for="task in tasks" :key="task.id" class="task-card">
      <div class="task-header">
        <h2>{{ task.title }}</h2>
        <p>积分: {{ task.points }}</p>
        <p>状态: {{ getTaskStatus(task) }}</p>
        <button @click="showDetails(task)" class="btn">详情</button>
        <button v-if="task.isMatched === false" @click="acceptTask(task.id)" class="btn accept-btn">接受任务</button>
      </div>
      <div v-if="selectedTask && selectedTask.id === task.id" class="task-details">
        <h3>详细信息</h3>
        <p><strong>描述:</strong> {{ task.description }}</p>
        <p><strong>类型:</strong> {{ task.taskType }}</p>
        <p><strong>截止时间:</strong> {{ new Date(task.deadline * 1000).toLocaleString() }}</p>
        <p><strong>发布者:</strong> {{ task.creator }}</p>
        <p><strong>接受者:</strong> {{ task.accepter || '尚未接受' }}</p>
        <p><strong>是否已完成:</strong> {{ task.isCompleted? '是' : '否' }}</p>
        <p><strong>是否存在争议:</strong> {{ task.isDisputed? '是' : '否' }}</p>
        <p v-if="task.disputedReason"><strong>争议原因:</strong> {{ task.disputedReason }}</p>
      </div>
    </div>
    <div class="create-task-section">
      <h2>发布新任务</h2>
      <label for="title">任务标题：</label>
      <input type="text" id="title" v-model="newTask.title" required>
      <label for="description">任务描述：</label>
      <textarea id="description" v-model="newTask.description" required></textarea>
      <label for="points">任务积分：</label>
      <input type="number" id="points" v-model="newTask.points" required>
      <label for="taskType">任务类型：</label>
      <input type="text" id="taskType" v-model="newTask.taskType" required>
      <label for="deadline">任务截止时间：</label>
      <input type="datetime-local" id="deadline" v-model="newTask.deadline" required>
      <button @click="createTask" class="btn">发布任务</button>
    </div>
  </div>
</template>

<script>
import { getAllTasks, acceptTask as acceptTaskWeb3, createTask as createTaskWeb3 } from '../api/contract';
export default {
  data() {
    return {
      tasks: [],
      selectedTask: null,
      newTask: {
        title: '',
        description: '',
        points: 0,
        taskType: '',
        deadline: ''
      }
    };
  },
  async created() {
    try {
      const tasks = await getAllTasks();
      this.tasks = tasks.map(task => {
        return {
      ...task,
          deadline: task.deadline? parseInt(task.deadline) : 0
        };
      });
    } catch (error) {
      console.error('获取任务失败', error);
    }
  },
  methods: {
    showDetails(task) {
      if (this.selectedTask && this.selectedTask.id === task.id) {
        this.selectedTask = null;
      } else {
        this.selectedTask = task;
      }
    },
    getTaskStatus(task) {
      if (task.isCompleted) {
        return '已完成';
      } else if (task.isMatched) {
        return '已匹配，进行中';
      } else {
        return '未匹配';
      }
    },
    async acceptTask(taskId) {
      try {
        await acceptTaskWeb3(taskId);
        // 接受任务成功后，更新任务列表（这里简单地重新获取所有任务，可根据实际情况优化）
        const tasks = await getAllTasks();
        this.tasks = tasks.map(task => {
          return {
        ...task,
            deadline: task.deadline? parseInt(task.deadline) : 0
          };
        });
      } catch (error) {
        console.error('接受任务失败', error);
      }
    },
    async createTask() {
      // 将前端时间格式转换为合约所需的时间戳格式（以秒为单位）
      const deadlineTimestamp = Math.floor(new Date(this.newTask.deadline).getTime() / 1000);
      try {
        await createTaskWeb3(
          this.newTask.title,
          this.newTask.description,
          this.newTask.points,
          this.newTask.taskType,
          deadlineTimestamp
        );
        // 发布任务成功后，清空表单并更新任务列表
        this.newTask = {
          title: '',
          description: '',
          points: 0,
          taskType: '',
          deadline: ''
        };
        const tasks = await getAllTasks();
        this.tasks = tasks.map(task => {
          return {
        ...task,
            deadline: task.deadline? parseInt(task.deadline) : 0
          };
        });
      } catch (error) {
        console.error('发布任务失败', error);
      }
    }
  }
};
</script>

<style scoped>
.all-tasks {
  text-align: center;
  margin-top: 50px;
  font-family: Arial, sans-serif;
}

.task-card {
  border: 1px solid #ccc;
  border-radius: 5px;
  padding: 15px;
  margin: 20px auto;
  width: 80%;
  max-width: 600px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.task-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.task-header h2 {
  margin: 0;
}

.task-header p {
  margin: 0;
  font-size: 1em;
  color: #555;
}

.task-details {
  margin-top: 20px;
  text-align: left;
}

.task-details h3 {
  margin-top: 0;
}

.task-details p {
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

.accept-btn {
  background-color: #007BFF;
}

.accept-btn:hover {
  background-color: #0056b3;
}

.create-task-section {
    margin-top: 30px;
    border: 1px solid #ccc;
    border-radius: 5px;
    padding: 20px;
    width: 80%;
    max-width: 600px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    margin: 0 auto; /* 新增代码，使整体水平居中 */
}

.create-task-section label {
    display: block;
    margin-bottom: 10px;
    font-size: 1em;
    color: #333;
    text-align: left;
    width: 100%;
}

.create-task-section input[type="text"],
.create-task-section textarea,
.create-task-section input[type="number"],
.create-task-section input[type="datetime-local"] {
    width: 100%;
    padding: 10px;
    margin-bottom: 20px;
    border: 1px solid #ccc;
    border-radius: 4px;
    font-size: 1em;
}
</style>