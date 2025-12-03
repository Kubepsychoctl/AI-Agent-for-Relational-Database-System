import os
import sys
from typing import Optional


GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY", "AIzaSyBhHG7TXXZI-VkCXo4D-ifkILG0z-dJzm8")

DB_CONFIG = {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "Cegthgegth_123", 
    "database": "hr_analytics"
}

try:
    from langchain_google_genai import ChatGoogleGenerativeAI
    from langchain_community.utilities import SQLDatabase
    from langchain_community.agent_toolkits import create_sql_agent
    from sqlalchemy import create_engine, text
    import pandas as pd
except ImportError as e:
    print(f"❌ Missing dependency: {e}")
    print("Run: pip install langchain langchain-google-genai langchain-community pymysql sqlalchemy tabulate")
    sys.exit(1)

def get_database_connection():
    """Create database connection"""
    connection_string = (
        f"mysql+pymysql://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
        f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
    )
    
    engine = create_engine(connection_string)
    db = SQLDatabase.from_uri(connection_string)
    
    # Test connection
    with engine.connect() as conn:
        conn.execute(text("SELECT 1"))
    
    return engine, db

CUSTOM_PREFIX = """
You are an expert HR Analytics AI agent connected to a MySQL database containing employee data.
The database has the following structure:

TABLES:
- Department: department_id (PK), department_name
- JobRole: job_role_id (PK), job_role_name  
- Education: education_id (PK), education_level, education_field
- Employee: employee_id (PK), department_id (FK), job_role_id (FK), education_id (FK), 
            age, gender, marital_status, distance_from_home, over_time, attrition, 
            business_travel, num_companies_worked, total_working_years
- Compensation: compensation_id (PK), employee_id (FK), monthly_income, daily_rate, 
                hourly_rate, monthly_rate, percent_salary_hike, stock_option_level
- JobHistory: job_history_id (PK), employee_id (FK), years_at_company, years_in_current_role,
              years_since_last_promotion, years_with_curr_manager, job_level, training_times_last_year
- Satisfaction: satisfaction_id (PK), employee_id (FK), environment_satisfaction, 
                job_satisfaction, relationship_satisfaction, work_life_balance, 
                job_involvement, performance_rating

VIEWS (pre-built for analysis):
- v_attrition_overview: Overall attrition statistics
- v_attrition_by_department: Attrition rates by department
- v_salary_attrition_comparison: Salary comparison between employees who left vs stayed
- v_overtime_attrition: Overtime impact on attrition
- v_burnout_risk: Employee burnout risk scores
- v_employee_full_analysis: Comprehensive employee data view

KEY INSIGHTS:
1. attrition = 1 means employee LEFT, attrition = 0 means STAYED
2. Satisfaction scores range from 1 (Low) to 4 (High)
3. over_time = 1 means Yes, 0 means No

Always provide clear, actionable insights after running queries.
"""

def create_agent(db):
    """Create the SQL Agent"""
    os.environ["GOOGLE_API_KEY"] = GOOGLE_API_KEY
    
    llm = ChatGoogleGenerativeAI(
        model="gemini-2.0-flash",
        temperature=0,
        convert_system_message_to_human=True
    )
    
    agent = create_sql_agent(
        llm=llm,
        db=db,
        agent_type="openai-tools",
        verbose=True,
        prefix=CUSTOM_PREFIX,
        handle_parsing_errors=True
    )
    
    return agent

def run_query(engine, query: str) -> pd.DataFrame:
    """Execute SQL query and return DataFrame"""
    with engine.connect() as conn:
        return pd.read_sql(query, conn)

def display_view(engine, view_name: str):
    """Display contents of a VIEW"""
    df = run_query(engine, f"SELECT * FROM {view_name}")
    print(f"\n{'='*60}")
    print(f"📊 {view_name}")
    print('='*60)
    print(df.to_string(index=False))
    print()
    return df

def ask_agent(agent, question: str) -> str:
    """Send question to AI agent"""
    print("\n" + "="*70)
    print(f"❓ QUESTION: {question}")
    print("="*70)
    
    try:
        response = agent.invoke({"input": question})
        print("\n" + "-"*70)
        print("💡 ANSWER:")
        print("-"*70)
        print(response["output"])
        return response["output"]
    except Exception as e:
        print(f"❌ Error: {e}")
        return str(e)


def analyze_problem_1(agent, engine):
    """Problem 1: Employee Attrition Analysis"""
    print("\n" + "🔴"*35)
    print("PROBLEM 1: Employee Attrition Analysis")
    print("🔴"*35)
    
    display_view(engine, "v_attrition_overview")
    
    ask_agent(agent, """
    Analyze the overall employee attrition in our company. 
    What is the attrition rate? Which demographic groups have the highest attrition?
    Provide 3 actionable recommendations.
    """)

def analyze_problem_2(agent, engine):
    """Problem 2: Department-wise Turnover"""
    print("\n" + "🟠"*35)
    print("PROBLEM 2: Department-wise Turnover Analysis")
    print("🟠"*35)
    
    display_view(engine, "v_attrition_by_department")
    
    ask_agent(agent, """
    Which departments have the highest and lowest attrition rates?
    What factors contribute to high attrition in the worst-performing department?
    """)

def analyze_problem_3(agent, engine):
    """Problem 3: Compensation Impact"""
    print("\n" + "🟡"*35)
    print("PROBLEM 3: Compensation Impact on Attrition")
    print("🟡"*35)
    
    display_view(engine, "v_salary_attrition_comparison")
    display_view(engine, "v_attrition_by_salary_bracket")
    
    ask_agent(agent, """
    Is there a significant salary difference between employees who left and stayed?
    What salary threshold reduces attrition significantly?
    What's the ROI of salary increases for retention?
    """)

def analyze_problem_4(agent, engine):
    """Problem 4: Burnout Risk"""
    print("\n" + "🟢"*35)
    print("PROBLEM 4: Burnout Risk Analysis")
    print("🟢"*35)
    
    display_view(engine, "v_overtime_attrition")
    display_view(engine, "v_high_burnout_risk")
    
    ask_agent(agent, """
    How does overtime affect attrition and work-life balance?
    How many employees are at high burnout risk (score >= 5)?
    What interventions would reduce burnout?
    """)

def generate_executive_summary(agent):
    """Generate comprehensive executive summary"""
    print("\n" + "⭐"*35)
    print("EXECUTIVE SUMMARY")
    print("⭐"*35)
    
    ask_agent(agent, """
    Generate an executive summary with:
    1. Current attrition rate vs industry average (15%)
    2. Top 3 factors driving attrition
    3. Department needing most attention
    4. Compensation analysis summary
    5. Burnout risk assessment
    6. Top 5 recommendations for HR leadership
    """)

def interactive_mode(agent):
    """Interactive Q&A mode"""
    print("\n" + "="*70)
    print("🤖 INTERACTIVE MODE")
    print("="*70)
    print("Ask any question about HR data. Type 'quit' to exit.\n")
    
    while True:
        try:
            question = input("You: ").strip()
            if question.lower() in ['quit', 'exit', 'q']:
                print("Goodbye")
                break
            if question:
                ask_agent(agent, question)
        except KeyboardInterrupt:
            print("\nGoodbye")
            break

def main():
    print("="*70)
    print("🤖 HR Analytics AI Agent")
    print("   LangChain + Gemini + MySQL")
    print("="*70)
    
    # Check API key
    if GOOGLE_API_KEY == "YOUR_GEMINI_API_KEY_HERE":
        print("❌ Please set your GOOGLE_API_KEY!")
        print("   Get it from: https://aistudio.google.com/apikey")
        print("   Then set: export GOOGLE_API_KEY='your-key-here'")
        sys.exit(1)
    
    print("\n📡 Connecting to database...")
    try:
        engine, db = get_database_connection()
        print(f"✅ Connected! Tables: {db.get_usable_table_names()}")
    except Exception as e:
        print(f" Database connection failed: {e}")
        sys.exit(1)
    print("\n🤖 Initializing AI Agent...")
    try:
        agent = create_agent(db)
        print("✅ Agent ready!")
    except Exception as e:
        print(f" Agent initialization failed: {e}")
        sys.exit(1)
    
    # Menu
    print("\n" + "="*70)
    print("SELECT ANALYSIS MODE:")
    print("="*70)
    print("1. Full Analysis (All 4 Problems)")
    print("2. Problem 1: Employee Attrition")
    print("3. Problem 2: Department Turnover")
    print("4. Problem 3: Compensation Impact")
    print("5. Problem 4: Burnout Risk")
    print("6. Executive Summary")
    print("7. Interactive Mode")
    print("0. Exit")
    print("="*70)
    
    choice = input("Enter choice (0-7): ").strip()
    
    if choice == "1":
        analyze_problem_1(agent, engine)
        analyze_problem_2(agent, engine)
        analyze_problem_3(agent, engine)
        analyze_problem_4(agent, engine)
        generate_executive_summary(agent)
    elif choice == "2":
        analyze_problem_1(agent, engine)
    elif choice == "3":
        analyze_problem_2(agent, engine)
    elif choice == "4":
        analyze_problem_3(agent, engine)
    elif choice == "5":
        analyze_problem_4(agent, engine)
    elif choice == "6":
        generate_executive_summary(agent)
    elif choice == "7":
        interactive_mode(agent)
    elif choice == "0":
        print("Goodbye")
    else:
        print("Invalid choice. Running interactive mode...")
        interactive_mode(agent)

if __name__ == "__main__":
    main()