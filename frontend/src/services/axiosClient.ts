import axios from "axios";

const API_HOSTNAME = 'http://localhost:3000';

export const apiClient = axios.create({
  baseURL: API_HOSTNAME,
  headers: {
    "Content-Type": "application/json",
    "Accept": "application/json",
  },
});


export function setTokenToApiClientHeader(token?: string) {
  console.log('setting token to api client header', token);
  if (token) {
    apiClient.defaults.headers["Authorization"] = `Bearer ${token}`;
  } else {
    delete apiClient.defaults.headers["Authorization"];
  }
}
