import { Routes } from '@angular/router';
import { LoginComponent } from './components/login/login.component';
import { AdminDashboard } from './components/admin-dashboard/admin-dashboard.component';
import { UserDashboard } from './components/user-dashboard/user-dashboard.component';

export const routes: Routes = [
  { path: '', component: LoginComponent },
  { path: 'admin', component: AdminDashboard },
  { path: 'user', component: UserDashboard },
  { path: '**', redirectTo: '' }
];