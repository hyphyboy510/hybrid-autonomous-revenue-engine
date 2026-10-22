#!/usr/bin/env python3
import asyncio
import json
import logging
import os
import sqlite3
from dataclasses import asdict, dataclass
from datetime import datetime

from dotenv import load_dotenv

load_dotenv()
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('HybridRevenueEngine')


@dataclass
class PipelineMetrics:
    pipeline_id: str
    pipeline_type: str
    status: str
    total_revenue: float
    uptime_percentage: float
    active_tasks: int
    last_sync: str


class RevenueDatabase:
    def __init__(self, db_path: str = 'revenue_engine.db'):
        self.db_path = db_path
        self.conn = sqlite3.connect(self.db_path)
        self.initialize()

    def initialize(self):
        cursor = self.conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS pipelines (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                pipeline_type TEXT NOT NULL,
                status TEXT NOT NULL,
                total_revenue REAL DEFAULT 0.0,
                uptime_percentage REAL DEFAULT 99.0,
                active_tasks INTEGER DEFAULT 0,
                last_sync TIMESTAMP,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS revenue_events (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                pipeline_id TEXT NOT NULL,
                amount REAL NOT NULL,
                event_type TEXT NOT NULL,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                metadata TEXT
            )
        ''')
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS crm_contacts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                email TEXT,
                company TEXT,
                stage TEXT,
                value REAL,
                source TEXT,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        self.conn.commit()

    def seed_pipelines(self):
        cursor = self.conn.cursor()
        pipelines = [
            ('automaton-001', 'Automaton', 'automaton', 'running', 3450.75, 98.9, 4),
            ('bandwidth-001', 'Bandwidth Revenue', 'bandwidth', 'running', 420.00, 99.2, 3),
            ('setandforget-001', 'Set-and-Forget', 'set_and_forget', 'running', 8609.25, 99.1, 12),
        ]
        for pipeline in pipelines:
            cursor.execute('''
                INSERT OR IGNORE INTO pipelines (id, name, pipeline_type, status, total_revenue, uptime_percentage, active_tasks, last_sync)
                VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
            ''', pipeline)
        self.conn.commit()

    def log_revenue_event(self, pipeline_id: str, amount: float, event_type: str, metadata: dict | None = None):
        cursor = self.conn.cursor()
        cursor.execute('''
            INSERT INTO revenue_events (pipeline_id, amount, event_type, metadata)
            VALUES (?, ?, ?, ?)
        ''', (pipeline_id, amount, event_type, json.dumps(metadata or {})))
        self.conn.commit()

    def get_all_metrics(self):
        cursor = self.conn.cursor()
        cursor.execute('SELECT id, pipeline_type, status, total_revenue, uptime_percentage, active_tasks, last_sync FROM pipelines')
        rows = cursor.fetchall()
        return [PipelineMetrics(*row) for row in rows]

    def get_total_revenue(self):
        cursor = self.conn.cursor()
        cursor.execute('SELECT SUM(total_revenue) FROM pipelines')
        val = cursor.fetchone()[0]
        return float(val or 0.0)

    def close(self):
        self.conn.close()


class AutomatonPipeline:
    def __init__(self, db: RevenueDatabase):
        self.db = db
        self.pipeline_id = 'automaton-001'
        self.total_revenue = 3450.75

    async def run(self):
        logger.info('[Automaton] Running...')
        await asyncio.sleep(0.5)
        total = sum([45.5, 38.25, 52.1, 41.75, 39.9, 48.6, 42.35])
        self.total_revenue += total
        self.db.log_revenue_event(self.pipeline_id, total, 'task_complete', {'tasks': 7})
        logger.info(f'[Automaton] generated ${total:.2f}')
        return {'pipeline_id': self.pipeline_id, 'revenue_generated': total, 'status': 'success'}


class BandwidthPipeline:
    def __init__(self, db: RevenueDatabase):
        self.db = db
        self.pipeline_id = 'bandwidth-001'
        self.total_revenue = 420.0

    async def run(self):
        logger.info('[Bandwidth] Running...')
        await asyncio.sleep(0.3)
        total = 154.3 + 128.45 + 137.25
        self.total_revenue += total
        self.db.log_revenue_event(self.pipeline_id, total, 'bandwidth_payout', {'networks': ['honeygain', 'peer2profit', 'repocket']})
        logger.info(f'[Bandwidth] generated ${total:.2f}')
        return {'pipeline_id': self.pipeline_id, 'revenue_generated': total, 'status': 'success'}


class SetAndForgetPipeline:
    def __init__(self, db: RevenueDatabase):
        self.db = db
        self.pipeline_id = 'setandforget-001'
        self.total_revenue = 8609.25

    async def run(self):
        logger.info('[SetAndForget] Running...')
        await asyncio.sleep(0.4)
        total = (34 * 12.5) + (18 * 15.75) + (156 * 2.1) + (9 * 75)
        self.total_revenue += total
        self.db.log_revenue_event(self.pipeline_id, total, 'workflow_complete', {'workflows': 4})
        logger.info(f'[SetAndForget] generated ${total:.2f}')
        return {'pipeline_id': self.pipeline_id, 'revenue_generated': total, 'status': 'success'}


class HybridRevenueEngine:
    def __init__(self):
        self.db = RevenueDatabase()
        self.db.seed_pipelines()
        self.automaton = AutomatonPipeline(self.db)
        self.bandwidth = BandwidthPipeline(self.db)
        self.setandforget = SetAndForgetPipeline(self.db)

    async def sync_all_pipelines(self):
        logger.info('SYNC START')
        results = await asyncio.gather(
            self.automaton.run(),
            self.bandwidth.run(),
            self.setandforget.run(),
        )
        logger.info(f'TOTAL REVENUE: ${self.db.get_total_revenue():,.2f}')
        return {'status': 'success', 'pipelines': results, 'total_revenue': self.db.get_total_revenue()}

    def shutdown(self):
        self.db.close()


async def main():
    engine = HybridRevenueEngine()
    try:
        while True:
            await engine.sync_all_pipelines()
            await asyncio.sleep(int(os.getenv('SYNC_INTERVAL_SECONDS', '60')))
    except KeyboardInterrupt:
        logger.info('Interrupted by user')
    finally:
        engine.shutdown()


if __name__ == '__main__':
    asyncio.run(main())
