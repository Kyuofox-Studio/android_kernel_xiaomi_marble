#include <linux/init.h>
#include <linux/module.h>

#include "helloworld.h"

int __init helloworld_init(void)
{
    pr_info("Welcome to use LMPERF kernel.\n");
    pr_info("Thanks for using!\n");
#if IS_ENABLED(CONFIG_LMPERF_TEST)
	pr_alert("*************************************************************");
	pr_alert("**     NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE    **");
	pr_alert("**                                                         **");
	pr_alert("**         You are running internal LMPERF kernel          **");
	pr_alert("**                                                         **");
	pr_alert("**     NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE    **");
	pr_alert("*************************************************************");
    pr_alert("Your are testing the LMPERF Kernel. Thank you for testing.");
    pr_alert("Please DO NOT share the test LMPERF kernel with other people.");
#endif
    return 0;
}

void helloworld_exit(void)
{
    pr_info("Have a nice day, see you next time!\n");
}

module_init(helloworld_init);
module_exit(helloworld_exit);

MODULE_AUTHOR("Levi Marvin <levimarvin@icloud.com>");
MODULE_DESCRIPTION("Print welcome message to kernel log");
MODULE_VERSION("0.1");
MODULE_LICENSE("GPL v2");
