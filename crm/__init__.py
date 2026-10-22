#!/usr/bin/env python3
from flask import Flask, jsonify
from flask_cors import CORS
from baseline_sync import RevenueDatabase

app = Flask(__name__)
CORS(app)
db = RevenueDatabase()

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/api/v1/metrics', methods=['GET'])
def metrics():
    return jsonify({
        'total_revenue': db.get_total_revenue(),
        'pipelines': [
            {'id': p.pipeline_id, 'type': p.pipeline_type, 'total_revenue': p.total_revenue} for p in db.get_all_metrics()
        ]
    }), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
