import type { Principal } from "@icp-sdk/core/principal";
export interface Some<T> {
    __kind__: "Some";
    value: T;
}
export interface None {
    __kind__: "None";
}
export type Option<T> = Some<T> | None;
export interface ChatMessage {
    content: string;
    sender: Variant_Puro_user;
    messageType: Variant_action_dialogue;
    timestamp: Time;
}
export type Time = bigint;
export interface UserProfile {
    name: string;
}
export enum UserRole {
    admin = "admin",
    user = "user",
    guest = "guest"
}
export enum Variant_Puro_user {
    Puro = "Puro",
    user = "user"
}
export enum Variant_action_dialogue {
    action = "action",
    dialogue = "dialogue"
}
export interface backendInterface {
    assignCallerUserRole(user: Principal, role: UserRole): Promise<void>;
    getCallerUserProfile(sessionId: string): Promise<UserProfile | null>;
    getCallerUserRole(): Promise<UserRole>;
    getHistory(sessionKey: string): Promise<Array<ChatMessage>>;
    getUserProfile(user: string): Promise<UserProfile | null>;
    isCallerAdmin(): Promise<boolean>;
    saveCallerUserProfile(sessionId: string, profile: UserProfile): Promise<void>;
    sendMessage(sessionKey: string, message: ChatMessage): Promise<ChatMessage>;
}
