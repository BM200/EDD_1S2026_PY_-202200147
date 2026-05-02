import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private url = 'http://localhost:3000'; // URL de tu servidor Perl

  constructor(private http: HttpClient) { }

  login(usuario: string, password: string): Observable<any> {
    return this.http.post(`${this.url}/login`, { usuario, password });
  }
}