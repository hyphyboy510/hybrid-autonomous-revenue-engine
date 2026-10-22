from crm.crm_data import seed_leads


def pipeline_summary():
    leads = seed_leads()
    total_value = sum(lead.value for lead in leads)
    stages = {}
    for lead in leads:
        stages[lead.stage] = stages.get(lead.stage, 0) + 1
    return {
        'lead_count': len(leads),
        'total_value': total_value,
        'stages': stages,
    }
