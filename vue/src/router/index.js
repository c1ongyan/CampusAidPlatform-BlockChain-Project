import Vue from 'vue'
import VueRouter from 'vue-router'
import TaskView from '@/views/TaskView.vue'
import ResourceView from '@/views/ResourceView.vue'
import JudgeView from '@/views/JudgeView.vue'
import AboutView from '@/views/AboutView.vue'
import HomeView from '@/views/HomeView.vue'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'task',
    component: TaskView
  },
  {
    path: '/home',
    name: 'home',
    component: HomeView
  },
  {
    path: '/judge',
    name: 'judge',
    component: JudgeView
  },
  {
    path: '/resource',
    name: 'resource',
    component: ResourceView
  },
  {
    path: '/about',
    name: 'about',
    component: AboutView
  }
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
