package cn.cstonline.openapi.proftest;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.Properties;

import org.apache.kafka.clients.consumer.ConsumerRebalanceListener;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.PartitionInfo;
import org.apache.kafka.common.TopicPartition;

public class ConsumerTest {
	public static void main(String[] args) {
		Properties props = new Properties();
		final TopicPartition[] par = new TopicPartition[8];
		props.put("bootstrap.servers", "172.16.1.62:9092,172.16.1.63:9092,172.16.1.49:9092");
		props.put("group.id", "perftest");
		props.put("enable.auto.commit", "true");
		props.put("auto.commit.interval.ms", "1000");
		props.put("auto.offset.reset", "earliest");
		props.put("session.timeout.ms", "30000");
		props.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
		props.put("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");

		final KafkaConsumer<String, String> kafkaConsumer = new KafkaConsumer<>(props);
		kafkaConsumer.subscribe(Arrays.asList("hellokafkatopic"), new ConsumerRebalanceListener() {

			@Override
			public void onPartitionsRevoked(Collection<TopicPartition> partitions) {

			}

			@Override
			public void onPartitionsAssigned(Collection<TopicPartition> partitions) {
				int i = 0;
				for (TopicPartition partition : partitions) {
					System.out.println(partition.toString());
					par[i] = partition;
					i++;
				}
				kafkaConsumer.seekToBeginning(par);
			}
		});
		for (PartitionInfo pi : kafkaConsumer.partitionsFor("hellokafkatopic")) {
			System.out.println(pi);
		}
		;
		while (true) {
			ConsumerRecords<String, String> records = kafkaConsumer.poll(100);
			for (ConsumerRecord<String, String> record : records) {
				System.out.printf("offset = %d, value = %s", record.offset(), record.value());
				System.out.println();
			}
		}

	}
}
