package com.example.upi_analyzer_app

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class DatabaseHelper(context: Context) : SQLiteOpenHelper(context, "upi_analyzer.db", null, 1) {
    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL("PRAGMA foreign_keys = ON;")
        db.execSQL("CREATE TABLE IF NOT EXISTS raw_messages (id TEXT PRIMARY KEY, raw_body TEXT NOT NULL, sanitized_body TEXT, timestamp INTEGER NOT NULL, status TEXT NOT NULL DEFAULT 'pending')")
        db.execSQL("CREATE TABLE IF NOT EXISTS transactions (transaction_id TEXT PRIMARY KEY, raw_message_id TEXT, amount REAL NOT NULL, currency TEXT NOT NULL DEFAULT 'INR', transaction_type TEXT NOT NULL, provider TEXT, merchant TEXT, category TEXT, confidence REAL NOT NULL, timestamp INTEGER NOT NULL, FOREIGN KEY (raw_message_id) REFERENCES raw_messages (id))")
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS transactions")
        db.execSQL("DROP TABLE IF EXISTS raw_messages")
        onCreate(db)
    }

    fun insertRawMessage(rawMessage: Map<String, Any>) {
        val db = writableDatabase
        val cv = ContentValues().apply {
            put("id", rawMessage["id"] as String)
            put("raw_body", rawMessage["raw_body"] as String)
            put("sanitized_body", rawMessage["sanitized_body"] as String? ?: "")
            put("timestamp", rawMessage["timestamp"] as Long)
            put("status", rawMessage["status"] as String? ?: "pending")
        }
        db.insert("raw_messages", null, cv)
    }
}
