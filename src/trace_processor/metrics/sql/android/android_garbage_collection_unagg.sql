--
-- Copyright 2024 The Android Open Source Project
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     https://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

SELECT RUN_METRIC('android/process_metadata.sql');

INCLUDE PERFETTO MODULE android.garbage_collection;
INCLUDE PERFETTO MODULE android.suspend;

DROP VIEW IF EXISTS android_garbage_collection_unagg_output;
CREATE PERFETTO VIEW android_garbage_collection_unagg_output AS
SELECT AndroidGarbageCollectionUnaggMetric(
  'gc_events', (
    SELECT RepeatedField(
      AndroidGarbageCollectionUnaggMetric_GarbageCollectionEvent(
        'thread_name', thread_name,
        'process_name', process_name,
        'gc_type', gc_type,
        'is_mark_compact', is_mark_compact,
        'reclaimed_mb', reclaimed_mb,
        'min_heap_mb', min_heap_mb,
        'max_heap_mb', max_heap_mb,
        'mb_per_ms_of_running_gc', reclaimed_mb/(gc_running_dur/1e6),
        'mb_per_ms_of_wall_gc', reclaimed_mb/(gc_dur/1e6),
        'gc_dur', gc_dur,
        'gc_running_dur', gc_running_dur,
        'gc_runnable_dur', gc_runnable_dur,
        'gc_unint_io_dur', gc_unint_io_dur,
        'gc_unint_non_io_dur', gc_unint_non_io_dur,
        'gc_int_dur', gc_int_dur,
        'gc_ts', gc_ts,
        'tid', tid,
        'pid', pid,
        'gc_monotonic_dur', _extract_duration_without_suspend(gc_ts, gc_dur),
        'process', metadata,
        'gc_count', 1
      ))
    FROM android_garbage_collection_events
    LEFT JOIN process_metadata using (upid)
  )
);
