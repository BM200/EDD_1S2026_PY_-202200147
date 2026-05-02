import { Component } from '@angular/core';

@Component({
  selector: 'app-login',
  standalone: true, // Asegúrate de que diga true
  imports: [],
  templateUrl: './login.component.html', // <--- Nombre corregido
  styleUrl: './login.component.css'     // <--- Nombre corregido
})
export class LoginComponent { } // El nombre de la clase SIEMPRE es LoginComponent