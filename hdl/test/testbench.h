#ifndef TEST_BENCH_H
#define TEST_BENCH_H

#include <verilated_vcd_c.h>

/* https://zipcpu.com/blog/2017/06/21/looking-at-verilator.html */
template<class MODULE>	class TESTBENCH {
    public:
        unsigned long	m_tickcount;
        MODULE	*m_core;
        VerilatedVcdC *m_trace;

        TESTBENCH(void) {
            m_core = new MODULE;
            m_tickcount = 0l;
            Verilated::traceEverOn(true);
        }

        virtual ~TESTBENCH(void) {
            delete m_core;
            m_core = NULL;
        }

        virtual	void opentrace(const char *vcdname) {
            if (!m_trace) {
                m_trace = new VerilatedVcdC;
                m_core->trace(m_trace, 99);
                m_trace->open(vcdname);
            }
        }

        virtual void close(void) {
            if (m_trace) {
                m_trace->close();
                m_trace = NULL;
            }
        }

        virtual void reset(void) {
            m_core->I_reset = 1;
            // Make sure any inheritance gets applied
            this->tick();
            m_core->I_reset = 0;
        }

        virtual void tick(void) {
            // Increment our own internal time reference
            m_tickcount++;

            // Make sure any combinatorial logic depending upon
            // inputs that may have changed before we called tick()
            // has settled before the rising edge of the clock.
            m_core->I_clk = 0;
            m_core->eval();

            if(m_trace) m_trace->dump(10*m_tickcount-2);

            // Rising edge
            m_core->I_clk = 1;
            m_core->eval();

            if(m_trace) m_trace->dump(10*m_tickcount);

            // Falling edge
            m_core->I_clk = 0;
            m_core->eval();

            if (m_trace) {
                // This portion, though, is a touch different.
                // After dumping our values as they exist on the
                // negative clock edge ...
                m_trace->dump(10*m_tickcount+5);
                //
                // We'll also need to make sure we flush any I/O to
                // the trace file, so that we can use the assert()
                // function between now and the next tick if we want to.
                m_trace->flush();
            }
        }

        virtual bool done(void) { return (Verilated::gotFinish()); }
};

#endif 
