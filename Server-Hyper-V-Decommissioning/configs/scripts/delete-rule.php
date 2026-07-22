<?php
require_once("config.inc");
require_once("util.inc");
require_once("filter.inc");
$target_ip = $argv[1];
$deleted = 0;
foreach ($config["filter"]["rule"] as $index => $rule) {
    if (isset($rule["source"]["address"]) && $rule["source"]["address"] == $target_ip) {
        unset($config["filter"]["rule"][$index]);
        $deleted++;
        echo "Deleted rule index: $index
";
    }
}
if ($deleted > 0) {
    write_config("Deleted rules for IP: ".$target_ip);
    filter_configure();
    echo "Done. ".$deleted." rule(s) deleted.
";
} else {
    echo "No rules found for IP: ".$target_ip."
";
}