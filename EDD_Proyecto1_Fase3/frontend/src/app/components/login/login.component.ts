import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms'; // <--- AGREGAR ESTO
import { ApiService } from '../../services/api.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [FormsModule], // <--- AGREGAR ESTO
  templateUrl: './login.component.html',
  styleUrl: './login.component.css'
})
export class LoginComponent {
  usuario = '';
  password = '';

  constructor(private api: ApiService, private router: Router) {}

  onLogin() {
    this.api.login(this.usuario, this.password).subscribe(res => {
      if (res.status === 'success') {
        alert('Bienvenido ' + res.nombre);
        this.router.navigate([res.rol === 'admin' ? '/admin' : '/user']);
      } else {
        alert('Error: ' + res.mensaje);
      }
    });
  }
}